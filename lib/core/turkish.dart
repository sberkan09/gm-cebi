/// Turkish text helpers: casing, search folding, collation and suffixes.
///
/// Dart's `toLowerCase`/`toUpperCase` are locale-independent, so `'I'` becomes
/// `'i'` and `'i'` becomes `'I'`. Turkish has four distinct letters (I ı İ i),
/// so every user-visible case change goes through these helpers.
/// Rules are summarised in docs/turkish-text.md.
library;

const _lowerMap = {'I': 'ı', 'İ': 'i'};
const _upperMap = {'i': 'İ', 'ı': 'I'};

/// Turkish lowercase: I → ı, İ → i.
String trLower(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    b.write(_lowerMap[c] ?? c.toLowerCase());
  }
  return b.toString();
}

/// Turkish uppercase: i → İ, ı → I.
String trUpper(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    b.write(_upperMap[c] ?? c.toUpperCase());
  }
  return b.toString();
}

/// Uppercases the first letter with Turkish rules ("istanbul" → "İstanbul").
String trCapitalize(String s) =>
    s.isEmpty ? s : trUpper(String.fromCharCode(s.runes.first)) + s.substring(String.fromCharCode(s.runes.first).length);

const _foldMap = {
  'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
  'â': 'a', 'î': 'i', 'û': 'u', 'é': 'e', '’': "'",
};

/// Search key: Turkish lowercase, then diacritics removed, so "cuce", "CÜCE"
/// and "Cüce" all match, and an English "I" still matches "i".
String trFold(String s) {
  // Fast path: plain ASCII folds like ASCII lowercase (I → ı → i).
  var ascii = true;
  for (var i = 0; i < s.length; i++) {
    if (s.codeUnitAt(i) > 0x7F) {
      ascii = false;
      break;
    }
  }
  if (ascii) return s.toLowerCase();
  final lower = trLower(s);
  final b = StringBuffer();
  for (final r in lower.runes) {
    final c = String.fromCharCode(r);
    b.write(_foldMap[c] ?? c);
  }
  return b.toString();
}

// ---------------------------------------------------------------- collation

const _alphabet = 'aâbcçdefgğhıiîjklmnoöpqrsştuüûvwxyz';
final Map<String, int> _rank = {
  for (var i = 0; i < _alphabet.length; i++) _alphabet[i]: i,
};

int _letterRank(String lowerChar) {
  // Circumflex vowels sort with their plain vowel.
  switch (lowerChar) {
    case 'â':
      return _rank['a']!;
    case 'î':
      return _rank['i']!;
    case 'û':
      return _rank['u']!;
  }
  final r = _rank[lowerChar];
  if (r != null) return r;
  final code = lowerChar.codeUnitAt(0);
  // Spaces and punctuation first (word-by-word order: "Ak Ejder" < "Akrep"),
  // then digits, then letters; other characters last.
  if (code <= 0x2F || (code >= 0x3A && code <= 0x40)) return -200 + code;
  if (code >= 0x30 && code <= 0x39) return -100 + (code - 0x30);
  return 1000 + code;
}

/// Compares two strings in Turkish alphabetical order (a b c ç d … ğ … ı i …),
/// case-insensitively first, then lowercase before uppercase.
int trCompare(String a, String b) {
  final la = trLower(a).runes.toList();
  final lb = trLower(b).runes.toList();
  final n = la.length < lb.length ? la.length : lb.length;
  for (var i = 0; i < n; i++) {
    if (la[i] == lb[i]) continue;
    final ra = _letterRank(String.fromCharCode(la[i]));
    final rb = _letterRank(String.fromCharCode(lb[i]));
    if (ra != rb) return ra.compareTo(rb);
  }
  if (la.length != lb.length) return la.length.compareTo(lb.length);
  return b.compareTo(a); // lowercase (higher code unit) first
}

// ---------------------------------------------------------------- suffixes

const _backVowels = 'aıou';
const _frontVowels = 'eiöü';
const _roundedVowels = 'ouöü';
const _hardConsonants = 'fstkçşhp'; // "fıstıkçı şahap"

/// How a number is read aloud, for choosing suffix vowels ("15'e", "40'a").
String numberReading(int n) {
  n = n.abs();
  if (n == 0) return 'sıfır';
  const ones = ['', 'bir', 'iki', 'üç', 'dört', 'beş', 'altı', 'yedi', 'sekiz', 'dokuz'];
  const tens = ['', 'on', 'yirmi', 'otuz', 'kırk', 'elli', 'altmış', 'yetmiş', 'seksen', 'doksan'];
  if (n % 1000000000 == 0) return 'milyar';
  if (n % 1000000 == 0) return 'milyon';
  if (n % 1000 == 0) return 'bin';
  if (n % 100 == 0) return 'yüz';
  if (n % 10 == 0) return tens[(n % 100) ~/ 10];
  return ones[n % 10];
}

const _letterNames = {
  'A': 'a', 'B': 'be', 'C': 'ce', 'Ç': 'çe', 'D': 'de', 'E': 'e', 'F': 'fe', 'G': 'ge', 'Ğ': 'yumuşak ge',
  'H': 'he', 'I': 'ı', 'İ': 'i', 'J': 'je', 'K': 'ke', 'L': 'le', 'M': 'me', 'N': 'ne', 'O': 'o', 'Ö': 'ö',
  'P': 'pe', 'Q': 'kü', 'R': 're', 'S': 'se', 'Ş': 'şe', 'T': 'te', 'U': 'u', 'Ü': 'ü', 'V': 've', 'W': 've',
  'X': 'iks', 'Y': 'ye', 'Z': 'ze',
};

final _abbrevRe = RegExp(r'^[A-ZÇĞİÖŞÜ]{2,5}$');

/// How the end of a word is pronounced, for choosing suffixes: numbers are
/// read aloud ("15" → "beş"), all-caps abbreviations by letter names
/// ("ZS" → "se", so "ZS'ye", "ZS'si").
String _readable(String word) {
  final n = int.tryParse(word);
  if (n != null) return numberReading(n);
  if (_abbrevRe.hasMatch(word)) return _letterNames[word[word.length - 1]] ?? trLower(word);
  return trLower(word);
}

String? _lastVowel(String w) {
  for (var i = w.length - 1; i >= 0; i--) {
    final c = w[i];
    if (_backVowels.contains(c) || _frontVowels.contains(c)) return c;
    if ('âîû'.contains(c)) return c == 'â' ? 'a' : (c == 'î' ? 'i' : 'u');
  }
  return null;
}

const _allVowels = 'aıoueiöüâîû';

bool _endsWithVowel(String w) => w.isNotEmpty && _allVowels.contains(w[w.length - 1]);

bool _endsHard(String w) => w.isNotEmpty && _hardConsonants.contains(w[w.length - 1]);

/// Two-way harmony vowel (a/e).
String _a(String w) => _backVowels.contains(_lastVowel(w) ?? 'e') ? 'a' : 'e';

/// Four-way harmony vowel (ı/i/u/ü).
String _i(String w) {
  final v = _lastVowel(w) ?? 'e';
  final back = _backVowels.contains(v);
  final round = _roundedVowels.contains(v);
  if (back) return round ? 'u' : 'ı';
  return round ? 'ü' : 'i';
}

enum TrCase {
  /// Yönelme: -a/-e (Goblin'e)
  dative,

  /// Bulunma: -da/-de/-ta/-te (3. turda)
  locative,

  /// Ayrılma: -dan/-den/-tan/-ten
  ablative,

  /// Belirtme: -ı/-i/-u/-ü (Goblin'i)
  accusative,

  /// İlgi: -ın/-in/-un/-ün (Goblin'in)
  genitive,
}

/// Appends a case suffix with vowel harmony, buffer letters and consonant
/// assimilation. Proper nouns, numbers and abbreviations take an apostrophe
/// (`apostrophe: true`). Consonant softening of the stem (kitap → kitabı) is
/// not applied; with an apostrophe Turkish does not soften proper nouns.
String withCase(String word, TrCase c, {bool apostrophe = false}) {
  if (word.isEmpty) return word;
  final r = _readable(word.split(RegExp(r'\s+')).last);
  final vowelEnd = _endsWithVowel(r);
  final hard = _endsHard(r);
  final a = _a(r);
  final i = _i(r);
  final String suffix;
  switch (c) {
    case TrCase.dative:
      suffix = vowelEnd ? 'y$a' : a;
    case TrCase.locative:
      suffix = '${hard ? 't' : 'd'}$a';
    case TrCase.ablative:
      suffix = '${hard ? 't' : 'd'}${a}n';
    case TrCase.accusative:
      suffix = vowelEnd ? 'y$i' : i;
    case TrCase.genitive:
      suffix = vowelEnd ? 'n${i}n' : '$i' 'n';
  }
  return apostrophe ? "$word'$suffix" : '$word$suffix';
}

/// Plural: -lar/-ler. Note: Turkish nouns stay singular after a number
/// ("3 goblin", not "3 goblinler"); use [countNoun] for that.
String plural(String word) => '$word${'l${_a(_readable(word))}r'}';

/// "3 tur", "1 büyü" — Turkish never pluralises after a cardinal number.
String countNoun(int n, String noun) => '$n $noun';

/// Ordinal with a dot: 3 → "3.", read "üçüncü".
String ordinal(int n) => '$n.';

/// Third-person possessive (izafet) for compound nouns:
/// "Oluşturma" + "Cantrip" → "Oluşturma Cantrip'i".
String possessive3(String word, {bool apostrophe = false}) {
  final r = _readable(word);
  final i = _i(r);
  final suffix = _endsWithVowel(r) ? 's$i' : i;
  return apostrophe ? "$word'$suffix" : '$word$suffix';
}
