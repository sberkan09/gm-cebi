/// Parsing and checking of the small whole numbers typed into stat fields
/// (initiative, bonus, HP, AC).
library;

/// Longest input a stat field accepts ("-999", "9999").
const statFieldMaxLength = 4;

/// A whole number with an optional leading minus (also "−"), at most
/// [statFieldMaxLength] characters. Anything else, such as "1-2" or "-", is
/// null rather than a silently dropped part.
int? parseStat(String s) {
  final t = s.trim().replaceAll('−', '-');
  if (t.length > statFieldMaxLength || !RegExp(r'^-?\d+$').hasMatch(t)) return null;
  return int.tryParse(t);
}

/// Error text for an optional stat field, or null when it is empty or valid.
String? statError(String s, {int? min}) {
  if (s.trim().isEmpty) return null;
  final v = parseStat(s);
  if (v == null) return 'Geçerli bir sayı yaz';
  if (min != null && v < min) return 'En az $min';
  return null;
}
