/// Dice expression parser and roller.
///
/// Grammar (whitespace ignored, case-insensitive):
///
///   expr    := term (('+' | '-') term)*
///   term    := unary (('*' | '/') unary)*
///   unary   := '-' unary | primary
///   primary := INT | dice | '(' expr ')'
///   dice    := INT? ('d' | 'z') (INT | '%') modifier*
///   modifier:= ('kh' | 'kl' | 'dh' | 'dl' | 'k') INT?
///
/// `k` is short for `kh`. A missing modifier count means 1. Division rounds
/// down, as 5e does. "z" is accepted for players used to Turkish "zar" (2z6).
/// Examples: `d20`, `2d20kh1+5`, `4d6dl1`, `8d6`, `(1d8+3)*2`, `d%`.
library;

import 'dart:math';

class DiceException implements Exception {
  DiceException(this.message, this.position);

  /// Turkish, user-facing.
  final String message;
  final int position;

  @override
  String toString() => 'DiceException($position): $message';
}

const maxDice = 100;
const maxSides = 1000;

enum KeepMode { keepHighest, keepLowest, dropHighest, dropLowest }

/// One die group in the expression, e.g. `2d20kh1`.
class DiceTerm {
  DiceTerm(this.count, this.sides, [this.keep, this.keepCount = 1]);

  final int count;
  final int sides;
  final KeepMode? keep;
  final int keepCount;

  String get notation {
    final m = switch (keep) {
      null => '',
      KeepMode.keepHighest => 'kh$keepCount',
      KeepMode.keepLowest => 'kl$keepCount',
      KeepMode.dropHighest => 'dh$keepCount',
      KeepMode.dropLowest => 'dl$keepCount',
    };
    return '${count}d${sides == 100 ? '%' : sides}$m';
  }
}

/// The dice of one [DiceTerm] after rolling; `kept[i]` is false for dropped dice.
class RolledTerm {
  RolledTerm(this.term, this.values, this.kept);

  final DiceTerm term;
  final List<int> values;
  final List<bool> kept;

  int get total {
    var t = 0;
    for (var i = 0; i < values.length; i++) {
      if (kept[i]) t += values[i];
    }
    return t;
  }

  bool get isNatural20 => term.sides == 20 && _keptValues.length == 1 && _keptValues.first == 20;
  bool get isNatural1 => term.sides == 20 && _keptValues.length == 1 && _keptValues.first == 1;

  List<int> get _keptValues => [for (var i = 0; i < values.length; i++) if (kept[i]) values[i]];
}

class RollResult {
  RollResult(this.expression, this.total, this.terms, this.breakdown);

  /// The expression as typed (trimmed).
  final String expression;
  final int total;
  final List<RolledTerm> terms;

  /// Human-readable working, e.g. `[17, (4)] + 5`; dropped dice in parentheses.
  final String breakdown;

  bool get isCritical => terms.length == 1 && terms.first.isNatural20;
  bool get isFumble => terms.length == 1 && terms.first.isNatural1;
}

// ---------------------------------------------------------------- AST

abstract class _Node {
  int eval(Random rng, List<RolledTerm> out, StringBuffer text);
}

class _Num extends _Node {
  _Num(this.value);
  final int value;

  @override
  int eval(Random rng, List<RolledTerm> out, StringBuffer text) {
    text.write(value);
    return value;
  }
}

class _Dice extends _Node {
  _Dice(this.term);
  final DiceTerm term;

  @override
  int eval(Random rng, List<RolledTerm> out, StringBuffer text) {
    final values = [for (var i = 0; i < term.count; i++) rng.nextInt(term.sides) + 1];
    final kept = List<bool>.filled(values.length, true);
    if (term.keep != null) {
      final order = List<int>.generate(values.length, (i) => i)
        ..sort((a, b) {
          final c = values[a].compareTo(values[b]);
          return c != 0 ? c : a.compareTo(b);
        }); // ascending by value, stable
      final k = term.keepCount;
      switch (term.keep!) {
        case KeepMode.keepHighest:
          for (final i in order.take(values.length - k)) {
            kept[i] = false;
          }
        case KeepMode.keepLowest:
          for (final i in order.skip(k)) {
            kept[i] = false;
          }
        case KeepMode.dropHighest:
          for (final i in order.skip(values.length - k)) {
            kept[i] = false;
          }
        case KeepMode.dropLowest:
          for (final i in order.take(k)) {
            kept[i] = false;
          }
      }
    }
    final rolled = RolledTerm(term, values, kept);
    out.add(rolled);
    text.write('[');
    text.write([
      for (var i = 0; i < values.length; i++) kept[i] ? '${values[i]}' : '(${values[i]})',
    ].join(', '));
    text.write(']');
    return rolled.total;
  }
}

class _Neg extends _Node {
  _Neg(this.inner);
  final _Node inner;

  @override
  int eval(Random rng, List<RolledTerm> out, StringBuffer text) {
    text.write('−');
    return -inner.eval(rng, out, text);
  }
}

class _Group extends _Node {
  _Group(this.inner);
  final _Node inner;

  @override
  int eval(Random rng, List<RolledTerm> out, StringBuffer text) {
    text.write('(');
    final v = inner.eval(rng, out, text);
    text.write(')');
    return v;
  }
}

class _Bin extends _Node {
  _Bin(this.op, this.left, this.right);
  final String op;
  final _Node left;
  final _Node right;

  @override
  int eval(Random rng, List<RolledTerm> out, StringBuffer text) {
    final l = left.eval(rng, out, text);
    text.write(switch (op) { '+' => ' + ', '-' => ' − ', '*' => ' × ', _ => ' ÷ ' });
    final r = right.eval(rng, out, text);
    switch (op) {
      case '+':
        return l + r;
      case '-':
        return l - r;
      case '*':
        return l * r;
      default:
        if (r == 0) throw DiceException('Sıfıra bölme', 0);
        return (l / r).floor();
    }
  }
}

// ---------------------------------------------------------------- parser

class DiceExpression {
  DiceExpression._(this.source, this._root, this.diceCount);

  final String source;
  final _Node _root;

  /// Total number of dice rolled per evaluation (for limits / UI hints).
  final int diceCount;

  /// Parses [input]; throws [DiceException] with a Turkish message.
  factory DiceExpression.parse(String input) {
    final p = _Parser(input);
    final root = p.parseAll();
    return DiceExpression._(input.trim(), root, p.diceCount);
  }

  static bool isValid(String input) {
    try {
      DiceExpression.parse(input);
      return true;
    } on DiceException {
      return false;
    }
  }

  RollResult roll([Random? rng]) {
    final terms = <RolledTerm>[];
    final text = StringBuffer();
    final total = _root.eval(rng ?? Random.secure(), terms, text);
    return RollResult(source, total, terms, text.toString());
  }
}

/// Convenience: parse and roll.
RollResult roll(String expression, [Random? rng]) => DiceExpression.parse(expression).roll(rng);

class _Parser {
  _Parser(String input) : s = input.toLowerCase().replaceAll('−', '-').replaceAll('×', '*');

  final String s;
  int pos = 0;
  int diceCount = 0;

  _Node parseAll() {
    _ws();
    if (pos >= s.length) throw DiceException('İfade boş', 0);
    final n = _expr();
    _ws();
    if (pos < s.length) throw DiceException('Beklenmeyen karakter: "${s[pos]}"', pos);
    return n;
  }

  void _ws() {
    while (pos < s.length && (s[pos] == ' ' || s[pos] == '\t')) {
      pos++;
    }
  }

  bool _eat(String c) {
    _ws();
    if (pos < s.length && s.startsWith(c, pos)) {
      pos += c.length;
      return true;
    }
    return false;
  }

  _Node _expr() {
    var left = _term();
    while (true) {
      if (_eat('+')) {
        left = _Bin('+', left, _term());
      } else if (_eat('-')) {
        left = _Bin('-', left, _term());
      } else {
        return left;
      }
    }
  }

  _Node _term() {
    var left = _unary();
    while (true) {
      if (_eat('*')) {
        left = _Bin('*', left, _unary());
      } else if (_eat('/')) {
        left = _Bin('/', left, _unary());
      } else {
        return left;
      }
    }
  }

  _Node _unary() {
    if (_eat('-')) return _Neg(_unary());
    if (_eat('+')) return _unary();
    return _primary();
  }

  int? _int() {
    _ws();
    final start = pos;
    while (pos < s.length && s.codeUnitAt(pos) >= 0x30 && s.codeUnitAt(pos) <= 0x39) {
      pos++;
    }
    if (pos == start) return null;
    final digits = s.substring(start, pos);
    if (digits.length > 6) throw DiceException('Sayı çok büyük', start);
    return int.parse(digits);
  }

  bool _isDieLetter() => pos < s.length && (s[pos] == 'd' || s[pos] == 'z');

  _Node _primary() {
    _ws();
    final start = pos;
    if (_eat('(')) {
      final inner = _expr();
      if (!_eat(')')) throw DiceException('Kapanmamış parantez', start);
      return _Group(inner);
    }
    final n = _int();
    _ws();
    if (_isDieLetter()) {
      // A modifier letter right after a number is never a die ("4d6dl1" handled in _dice).
      return _dice(n ?? 1, start);
    }
    if (n == null) {
      if (pos >= s.length) throw DiceException('İfade eksik', pos);
      throw DiceException('Beklenmeyen karakter: "${s[pos]}"', pos);
    }
    return _Num(n);
  }

  _Node _dice(int count, int start) {
    pos++; // d / z
    int sides;
    if (pos < s.length && s[pos] == '%') {
      pos++;
      sides = 100;
    } else {
      final v = _int();
      if (v == null) throw DiceException('Zarın yüz sayısı eksik (ör. d20)', pos);
      sides = v;
    }
    if (count < 1) throw DiceException('En az 1 zar atılmalı', start);
    if (count > maxDice) throw DiceException('Tek seferde en fazla $maxDice zar', start);
    if (sides < 2) throw DiceException('Zarın en az 2 yüzü olmalı', start);
    if (sides > maxSides) throw DiceException('Zarın en fazla $maxSides yüzü olabilir', start);
    diceCount += count;
    if (diceCount > maxDice * 2) throw DiceException('İfadede çok fazla zar var', start);

    KeepMode? mode;
    var k = 1;
    _ws();
    final modStart = pos;
    if (s.startsWith('kh', pos)) {
      mode = KeepMode.keepHighest;
      pos += 2;
    } else if (s.startsWith('kl', pos)) {
      mode = KeepMode.keepLowest;
      pos += 2;
    } else if (s.startsWith('dh', pos)) {
      mode = KeepMode.dropHighest;
      pos += 2;
    } else if (s.startsWith('dl', pos)) {
      mode = KeepMode.dropLowest;
      pos += 2;
    } else if (pos < s.length && s[pos] == 'k') {
      mode = KeepMode.keepHighest;
      pos += 1;
    }
    if (mode != null) {
      k = _int() ?? 1;
      final keepsOrDrops = mode == KeepMode.keepHighest || mode == KeepMode.keepLowest;
      if (k < 1 || (keepsOrDrops ? k > count : k >= count)) {
        throw DiceException(
          keepsOrDrops ? 'Tutulan zar sayısı 1 ile $count arasında olmalı' : 'Atılan zar sayısı ${count - 1} veya daha az olmalı',
          modStart,
        );
      }
    }
    return _Dice(DiceTerm(count, sides, mode, k));
  }
}

/// Expressions for the quick buttons.
String advantageExpression(int modifier) => '2d20kh1${_mod(modifier)}';
String disadvantageExpression(int modifier) => '2d20kl1${_mod(modifier)}';
String _mod(int m) => m == 0 ? '' : (m > 0 ? '+$m' : '$m');
