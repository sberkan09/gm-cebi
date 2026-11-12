/// Offline search over all reference records, Turkish and English at once.
///
/// Every record contributes its names (Turkish, English, glossary alias) and
/// its body text in both languages. Text is folded with [trFold], so case,
/// dotted/dotless i and diacritics never matter ("cuce" finds "Cüce").
///
/// Lookup: each query word must be a prefix of some word of the record
/// (names or body); records whose name contains the whole query as a
/// substring are added too. Hits are ranked by how well the *name* matches,
/// so "kör" puts the Blinded condition before every rule that mentions it.
///
/// Inflected queries ("can puanları", "körün", "iskeletin") are matched to
/// names through their Turkish stems ([trStems]) when the words as typed match
/// no record name. Glossary terms step back when a real record matches by name.
library;

import 'dart:typed_data';

import '../core/markdown.dart';
import '../core/turkish.dart';
import 'reference.dart';

class SearchHit {
  SearchHit(this.record, this.score, {this.approximate = false, this.index = 0});

  final RefRecord record;
  final double score;

  /// Position in the index (internal, for tie-breaking).
  final int index;

  /// True when the hit came from a stem of the query ("körün" → "Kör") or
  /// from the suffix-trimming fallback.
  final bool approximate;
}

class SearchResults {
  const SearchResults(this.hits, this.total);

  /// The best hits, at most the requested limit.
  final List<SearchHit> hits;

  /// Number of matching records, including those beyond the limit.
  final int total;
}

/// The query as typed, lowercased two ways for the same-spelling bonus:
/// Turkish rules for Turkish names, plain rules for English names (Turkish
/// lowercase would turn "Invisible" into "ınvisible").
class _Spelling {
  const _Spelling(this.tr, this.en);

  final String tr;
  final String en;
}

// Text is folded first, so Turkish letters are already ASCII; Latin-1/Extended
// letters are kept for the odd foreign name.
final _wordRe = RegExp('[a-z0-9\u00C0-\u024F]+');

List<String> _words(String folded) => [for (final m in _wordRe.allMatches(folded)) m.group(0)!];

class SearchIndex {
  SearchIndex._(this._records, this._names, this._nameWords, this._vocab, this._postings, this._nameVocab,
      this._namePostings, this._lowerEn, this._lowerTr);

  final List<RefRecord> _records;
  final List<List<String>> _names; // folded names per record
  final List<List<List<String>>> _nameWords;
  final List<String> _vocab; // sorted unique words
  final List<List<int>> _postings; // record indices per vocab word, ascending
  final List<String> _nameVocab; // sorted unique words of names only
  final List<List<int>> _namePostings; // record indices per name word, ascending
  final List<String> _lowerEn; // English name, plain lowercase
  final List<List<String>> _lowerTr; // Turkish names, Turkish lowercase (diacritics kept)

  int get size => _records.length;

  factory SearchIndex.build(ReferenceData data) {
    final records = data.all.toList();
    final names = <List<String>>[];
    final lowerEn = <String>[];
    final lowerTr = <List<String>>[];
    final nameWords = <List<List<String>>>[];
    final wordToRecs = <String, List<int>>{};
    final nameWordToRecs = <String, List<int>>{};

    void addWord(Map<String, List<int>> to, String w, int i) {
      final list = to.putIfAbsent(w, () => <int>[]);
      if (list.isEmpty || list.last != i) list.add(i);
    }

    for (var i = 0; i < records.length; i++) {
      final r = records[i];
      final ns = <String>{
        trFold(r.enName),
        if (r.trName != null) trFold(r.trName!),
        if (r.aliasTr != null) trFold(r.aliasTr!),
      }.toList();
      names.add(ns);
      lowerEn.add(r.enName.toLowerCase());
      lowerTr.add([
        if (r.trName != null) trLower(r.trName!),
        if (r.aliasTr != null) trLower(r.aliasTr!),
      ]);
      nameWords.add([for (final n in ns) _words(n)]);
      final seen = <String>{};
      for (final n in ns) {
        seen.addAll(_words(n));
      }
      for (final w in seen) {
        addWord(nameWordToRecs, w, i);
      }
      _collect(r.en, seen);
      if (r.tr != null) _collect(r.tr!, seen);
      for (final w in seen) {
        addWord(wordToRecs, w, i);
      }
    }
    final vocab = wordToRecs.keys.toList()..sort();
    final postings = [for (final w in vocab) wordToRecs[w]!];
    final nameVocab = nameWordToRecs.keys.toList()..sort();
    final namePostings = [for (final w in nameVocab) nameWordToRecs[w]!];
    return SearchIndex._(records, names, nameWords, vocab, postings, nameVocab, namePostings, lowerEn, lowerTr);
  }

  static const _skipKeys = {'id', 'kind', 'source'};

  /// Body words of a record: everything except ids, source refs and the
  /// top-level name (names are scored separately).
  static void _collect(Map<String, dynamic> record, Set<String> out) {
    record.forEach((k, v) {
      if (k != 'name') _walk(v, out, k);
    });
  }

  static void _walk(Object? node, Set<String> out, String key) {
    if (_skipKeys.contains(key)) return;
    if (node is String) {
      out.addAll(_words(trFold(stripMarkup(node))));
    } else if (node is Map) {
      node.forEach((k, v) => _walk(v, out, k as String));
    } else if (node is List) {
      for (final v in node) {
        _walk(v, out, key);
      }
    }
  }

  /// Indices of [vocab] words starting with [prefix].
  static (int, int) _range(List<String> vocab, String prefix) {
    var lo = 0, hi = vocab.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (vocab[mid].compareTo(prefix) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final start = lo;
    hi = vocab.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (vocab[mid].startsWith(prefix) || vocab[mid].compareTo(prefix) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return (start, lo);
  }

  /// Marks every record that has a word (name or body) starting with [token].
  void _markPrefix(String token, Uint8List mark) {
    final (a, b) = _range(_vocab, token);
    for (var i = a; i < b; i++) {
      for (final r in _postings[i]) {
        mark[r] = 1;
      }
    }
  }

  /// Marks every record with a name word starting with [token].
  void _markNamePrefix(String token, Uint8List mark) {
    final (a, b) = _range(_nameVocab, token);
    for (var i = a; i < b; i++) {
      for (final r in _namePostings[i]) {
        mark[r] = 1;
      }
    }
  }

  /// [only] restricts hits to one dataset (e.g. the monster picker).
  List<SearchHit> search(String query, {int limit = 60, String? only}) => searchAll(query, limit: limit, only: only).hits;

  /// Like [search], with the number of matches beyond [limit].
  SearchResults searchAll(String query, {int limit = 60, String? only}) {
    final q = _Query.parse(query);
    if (q == null) return const SearchResults([], 0);
    final tokens = q.tokens;
    var hits = _run(q.folded, tokens, q.spelling, only, approximate: false);
    bool named(SearchHit h) => h.score - h.record.info.priority > _bodyScore;
    // No real record matched by name (only body text, a glossary term, or
    // nothing): try the Turkish stems of the words on names, "körün" → "kör",
    // "can puanları" → "can puan". Body hits stay, ranked below them.
    if (!hits.any((h) => named(h) && h.record.dataset != _terms)) {
      var approx = _runStems(q, only);
      if (approx.isEmpty && !hits.any(named)) {
        // Not a suffix we know ("zehirlendi", a typo at the end): cut up to three
        // letters. Names only (body prefixes of short stems are mostly noise),
        // stems of 3+ letters.
        for (var cut = 1; cut <= 3 && approx.isEmpty; cut++) {
          final trimmed = [for (final t in tokens) t.length - cut >= 3 ? t.substring(0, t.length - cut) : t];
          if (trimmed.join() == tokens.join()) break;
          approx = _run(trimmed.join(' '), trimmed, q.spelling, only, approximate: true);
        }
      }
      if (approx.isNotEmpty) {
        final best = {for (final h in approx) h.index: h};
        for (final h in hits) {
          final other = best[h.index];
          if (other == null || h.score >= other.score) best[h.index] = h;
        }
        hits = best.values.toList();
      }
    }
    // A glossary term only says how a word is translated: when a rule, monster,
    // spell… matches by name, the terms go below all of them ("goblin" → the
    // goblins, then the Goblin language term), still above body-text matches.
    if (hits.any((h) => named(h) && h.record.dataset != _terms)) {
      for (var i = 0; i < hits.length; i++) {
        final h = hits[i];
        if (h.record.dataset == _terms && named(h)) {
          hits[i] = SearchHit(h.record, _termScore + h.score / 100, approximate: h.approximate, index: h.index);
        }
      }
    }
    // Ties: alphabetical by the folded English name (cheap; precomputed).
    hits.sort((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : _names[a.index][0].compareTo(_names[b.index][0]);
    });
    return SearchResults(hits.length > limit ? hits.sublist(0, limit) : hits, hits.length);
  }

  List<SearchHit> _run(String q, List<String> tokens, _Spelling spelling, String? only, {required bool approximate}) {
    final n = _records.length;
    // AND over tokens. One-letter tokens (and the approximate fallback) only
    // match names: as body prefixes they would match almost everything.
    Uint8List? cand;
    for (final t in tokens) {
      final mark = Uint8List(n);
      if (t.length == 1 || approximate) {
        _markNamePrefix(t, mark);
      } else {
        _markPrefix(t, mark);
      }
      if (cand == null) {
        cand = mark;
      } else {
        for (var i = 0; i < n; i++) {
          cand[i] &= mark[i];
        }
      }
    }
    final hits = <SearchHit>[];
    for (var i = 0; i < n; i++) {
      if (only != null && _records[i].dataset != only) continue;
      if ((cand != null && cand[i] == 1) || (!approximate && _names[i].any((name) => name.contains(q)))) {
        hits.add(SearchHit(_records[i], _score(i, q, tokens, spelling), approximate: approximate, index: i));
      }
    }
    return hits;
  }

  /// Name matches through Turkish stems: every query word, as typed or as one
  /// of its stems, must start a word of the same name.
  List<SearchHit> _runStems(_Query q, String? only) {
    final alts = [for (final t in q.tokens) [t, ...trStems(t)]];
    if (alts.every((a) => a.length == 1)) return const [];
    final n = _records.length;
    Uint8List? cand;
    for (final a in alts) {
      final mark = Uint8List(n);
      for (final s in a) {
        _markNamePrefix(s, mark);
      }
      if (cand == null) {
        cand = mark;
      } else {
        for (var i = 0; i < n; i++) {
          cand[i] &= mark[i];
        }
      }
    }
    final hits = <SearchHit>[];
    for (var i = 0; i < n; i++) {
      if (cand![i] == 0 || (only != null && _records[i].dataset != only)) continue;
      final s = _stemScore(i, q, alts);
      if (s > 0) hits.add(SearchHit(_records[i], s, approximate: true, index: i));
    }
    return hits;
  }

  static const _terms = 'terms';
  static const _bodyScore = 100.0;

  /// Demoted glossary terms: above body-only matches (at most 130), below every name match.
  static const _termScore = 200.0;

  /// Same spelling including ç ğ ı ö ş ü beats a folded match ("kör" → Kör before Korucu).
  static const _spellingBonus = 150.0;

  /// Each letter a stem is shorter than the typed word costs this much, so
  /// "büyüleri" lists "Büyüler" before "Büyü" whatever their datasets are.
  static const _stemPenalty = 30.0;
  static const _maxStemPenalty = 180.0;

  /// How well [name] matches the query, 0 when it does not.
  static double _tier(String name, List<String> words, String q, List<String> tokens) {
    if (name == q) return 1000;
    if (name.startsWith(q)) return 800;
    if (tokens.every((t) => words.any((w) => w.startsWith(t)))) {
      return 600 + (words.isNotEmpty && words.first.startsWith(tokens.first) ? 50 : 0);
    }
    if (name.contains(q)) return 400;
    return 0;
  }

  bool _sameSpelling(int i, _Spelling s) =>
      (s.en.isNotEmpty && _lowerEn[i].startsWith(s.en)) || (s.tr.isNotEmpty && _lowerTr[i].any((n) => n.startsWith(s.tr)));

  double _score(int i, String q, List<String> tokens, _Spelling spelling) {
    var best = _bodyScore; // body-only match
    for (var n = 0; n < _names[i].length; n++) {
      final name = _names[i][n];
      var s = _tier(name, _nameWords[i][n], q, tokens);
      if (s == 0) continue;
      s -= name.length / 100; // shorter names first
      if (s > best) best = s;
    }
    if (best > _bodyScore && _sameSpelling(i, spelling)) best += _spellingBonus;
    return best + _records[i].info.priority;
  }

  /// Score of the best name of record [i] when query words may be replaced by
  /// their stems ([alts]: the word as typed, then its stems, longest first);
  /// 0 when no name matches or when no stem was needed.
  double _stemScore(int i, _Query q, List<List<String>> alts) {
    var best = 0.0;
    final picks = List<String>.filled(alts.length, '');
    for (var n = 0; n < _names[i].length; n++) {
      final words = _nameWords[i][n];
      var stripped = 0;
      var matched = true;
      for (var j = 0; j < alts.length && matched; j++) {
        matched = false;
        for (final a in alts[j]) {
          if (words.any((w) => w.startsWith(a))) {
            picks[j] = a;
            stripped += alts[j][0].length - a.length;
            matched = true;
            break;
          }
        }
      }
      if (!matched || stripped == 0) continue; // as typed: the plain run scores it
      final name = _names[i][n];
      var s = _tier(name, words, q.withStems(q.folded, picks), picks) - name.length / 100;
      final penalty = stripped * _stemPenalty;
      s -= penalty < _maxStemPenalty ? penalty : _maxStemPenalty;
      if (_sameSpelling(i, _Spelling(q.withStems(q.spelling.tr, picks), q.withStems(q.spelling.en, picks)))) s += _spellingBonus;
      if (s > best) best = s;
    }
    return best == 0 ? 0 : best + _records[i].info.priority;
  }
}

/// A parsed query: folded text and words, plus the text as typed (lowercased)
/// for the same-spelling bonus.
class _Query {
  _Query._(this.folded, this.tokens, this._spans, this.spelling);

  final String folded;
  final List<String> tokens;
  final List<RegExpMatch> _spans; // token positions in [folded]
  final _Spelling spelling;

  static final _spaces = RegExp(r'\s+');

  static String _clean(String s) => s.trim().replaceAll(_spaces, ' ');

  static _Query? parse(String query) {
    final folded = _clean(trFold(query));
    if (folded.isEmpty) return null;
    final spans = _wordRe.allMatches(folded).toList();
    if (spans.isEmpty) return null;
    return _Query._(folded, [for (final m in spans) m.group(0)!], spans, _Spelling(_clean(trLower(query)), _clean(query.toLowerCase())));
  }

  /// [text] (the folded query, or a lowercased one of the same length) from
  /// its first to its last word, each word cut down to the stem picked for it.
  /// A softened stem ("kitab" → "kitap") is not a cut: it is used as it is.
  String withStems(String text, List<String> picks) {
    if (text.length != folded.length) return ''; // lowercasing changed the length ("İ" → "i̇")
    final b = StringBuffer();
    for (var j = 0; j < _spans.length; j++) {
      if (j > 0) b.write(text.substring(_spans[j - 1].end, _spans[j].start));
      final p = picks[j];
      b.write(tokens[j].startsWith(p) ? text.substring(_spans[j].start, _spans[j].start + p.length) : p);
    }
    return b.toString();
  }
}
