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

  /// True when the hit came from the suffix-trimming fallback.
  final bool approximate;
}

// Text is folded first, so Turkish letters are already ASCII; Latin-1/Extended
// letters are kept for the odd foreign name.
final _wordRe = RegExp('[a-z0-9\u00C0-\u024F]+');

List<String> _words(String folded) => [for (final m in _wordRe.allMatches(folded)) m.group(0)!];

class SearchIndex {
  SearchIndex._(this._records, this._names, this._nameWords, this._vocab, this._postings);

  final List<RefRecord> _records;
  final List<List<String>> _names; // folded names per record
  final List<List<List<String>>> _nameWords;
  final List<String> _vocab; // sorted unique words
  final List<List<int>> _postings; // record indices per vocab word, ascending

  int get size => _records.length;

  factory SearchIndex.build(ReferenceData data) {
    final records = data.all.toList();
    final names = <List<String>>[];
    final nameWords = <List<List<String>>>[];
    final wordToRecs = <String, List<int>>{};

    void addWord(String w, int i) {
      final list = wordToRecs.putIfAbsent(w, () => <int>[]);
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
      nameWords.add([for (final n in ns) _words(n)]);
      final seen = <String>{};
      for (final n in ns) {
        seen.addAll(_words(n));
      }
      _collect(r.en, seen);
      if (r.tr != null) _collect(r.tr!, seen);
      for (final w in seen) {
        addWord(w, i);
      }
    }
    final vocab = wordToRecs.keys.toList()..sort();
    final postings = [for (final w in vocab) wordToRecs[w]!];
    return SearchIndex._(records, names, nameWords, vocab, postings);
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

  /// Indices of vocabulary words starting with [prefix].
  (int, int) _range(String prefix) {
    var lo = 0, hi = _vocab.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_vocab[mid].compareTo(prefix) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final start = lo;
    hi = _vocab.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_vocab[mid].startsWith(prefix) || _vocab[mid].compareTo(prefix) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return (start, lo);
  }

  /// Marks every record that has a word starting with [token].
  void _markPrefix(String token, Uint8List mark) {
    final (a, b) = _range(token);
    for (var i = a; i < b; i++) {
      for (final r in _postings[i]) {
        mark[r] = 1;
      }
    }
  }

  List<SearchHit> search(String query, {int limit = 60}) {
    final q = trFold(query).trim().replaceAll(RegExp(r'\s+'), ' ');
    if (q.isEmpty) return const [];
    final tokens = _words(q);
    if (tokens.isEmpty) return const [];
    var hits = _run(q, tokens, approximate: false);
    if (hits.isEmpty) {
      // Turkish suffixes: "körlük" → "kör", "büyüleri" → "büyü".
      for (var cut = 1; cut <= 3 && hits.isEmpty; cut++) {
        final trimmed = [for (final t in tokens) t.length - cut >= 3 ? t.substring(0, t.length - cut) : t];
        if (trimmed.join() == tokens.join()) break;
        hits = _run(trimmed.join(' '), trimmed, approximate: true);
      }
    }
    // Ties: alphabetical by the folded English name (cheap; precomputed).
    hits.sort((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : _names[a.index][0].compareTo(_names[b.index][0]);
    });
    return hits.length > limit ? hits.sublist(0, limit) : hits;
  }

  List<SearchHit> _run(String q, List<String> tokens, {required bool approximate}) {
    final n = _records.length;
    // AND over tokens. One-letter tokens only match names: as a body prefix
    // they would match almost everything and cost the most.
    Uint8List? cand;
    for (final t in tokens) {
      final mark = Uint8List(n);
      if (t.length == 1) {
        for (var i = 0; i < n; i++) {
          if (_nameWords[i].any((ws) => ws.any((w) => w.startsWith(t)))) mark[i] = 1;
        }
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
      if ((cand != null && cand[i] == 1) || _names[i].any((name) => name.contains(q))) {
        hits.add(SearchHit(_records[i], _score(i, q, tokens), approximate: approximate, index: i));
      }
    }
    return hits;
  }

  double _score(int i, String q, List<String> tokens) {
    var best = 100.0; // body-only match
    for (var n = 0; n < _names[i].length; n++) {
      final name = _names[i][n];
      final words = _nameWords[i][n];
      double s;
      if (name == q) {
        s = 1000;
      } else if (name.startsWith(q)) {
        s = 800;
      } else if (tokens.every((t) => words.any((w) => w.startsWith(t)))) {
        s = 600 + (words.isNotEmpty && words.first.startsWith(tokens.first) ? 50 : 0);
      } else if (name.contains(q)) {
        s = 400;
      } else {
        continue;
      }
      s -= name.length / 100; // shorter names first
      if (s > best) best = s;
    }
    return best + _records[i].info.priority;
  }
}
