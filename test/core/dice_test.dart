import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/core/dice.dart';

/// Returns the given die faces in order (each value is the face, 1-based).
class FixedRandom implements Random {
  FixedRandom(this.faces);
  final List<int> faces;
  var _i = 0;

  @override
  int nextInt(int max) {
    final f = faces[_i++ % faces.length];
    expect(f, inInclusiveRange(1, max));
    return f - 1;
  }

  @override
  bool nextBool() => throw UnimplementedError();
  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test('plain numbers and arithmetic', () {
    expect(roll('5').total, 5);
    expect(roll('2+3*4').total, 14);
    expect(roll('(2+3)*4').total, 20);
    expect(roll('7/2').total, 3); // rounds down
    expect(roll('-3+1').total, -2);
  });

  test('2d20kh1+5 keeps the highest (advantage)', () {
    final r = roll('2d20kh1+5', FixedRandom([4, 17]));
    expect(r.total, 22);
    expect(r.terms.single.kept, [false, true]);
    expect(r.breakdown, '[(4), 17] + 5');
  });

  test('2d20kl1 keeps the lowest (disadvantage)', () {
    expect(roll('2d20kl1', FixedRandom([4, 17])).total, 4);
    expect(roll(disadvantageExpression(-1), FixedRandom([9, 12])).total, 8);
    expect(advantageExpression(3), '2d20kh1+3');
  });

  test('4d6dl1 drops the lowest (ability scores)', () {
    final r = roll('4d6dl1', FixedRandom([3, 6, 1, 5]));
    expect(r.total, 14);
    expect(r.terms.single.kept, [true, true, false, true]);
  });

  test('ties drop exactly one die', () {
    final r = roll('3d6dh1', FixedRandom([6, 6, 2]));
    expect(r.total, 8);
    final dropped = [for (var i = 0; i < 3; i++) if (!r.terms.single.kept[i]) r.terms.single.values[i]];
    expect(dropped, [6]);
  });

  test('implicit count, percentile, z alias, case and spaces', () {
    expect(roll('d20', FixedRandom([13])).total, 13);
    expect(roll('d%', FixedRandom([77])).total, 77);
    expect(roll('2z6', FixedRandom([2, 3])).total, 5);
    expect(roll(' 1D8 + 2 ', FixedRandom([8])).total, 10);
    expect(roll('2d20k', FixedRandom([2, 9])).total, 9);
  });

  test('critical and fumble flags on a single d20', () {
    expect(roll('1d20+5', FixedRandom([20])).isCritical, isTrue);
    expect(roll('2d20kh1', FixedRandom([1, 20])).isCritical, isTrue);
    expect(roll('2d20kl1', FixedRandom([1, 20])).isFumble, isTrue);
    expect(roll('1d6', FixedRandom([1])).isFumble, isFalse);
  });

  test('natural 20 and 1 are reported for the one kept d20, whatever else is rolled', () {
    expect(roll('1d20+1d4', FixedRandom([20, 2])).isCritical, isTrue, reason: 'Bless');
    expect(roll('1d20+1d4+5', FixedRandom([20, 3])).isCritical, isTrue);
    expect(roll('1d4+1d20-2', FixedRandom([3, 1])).isFumble, isTrue);
    expect(roll('2d20kh1+1d4', FixedRandom([1, 20, 4])).isCritical, isTrue);
    expect(roll('2d20kl1+2d6+3', FixedRandom([1, 20, 6, 6])).isFumble, isTrue);
    expect(roll('1d20+1d4', FixedRandom([19, 4])).isCritical, isFalse);
    expect(roll('1d20+1d4', FixedRandom([2, 1])).isFumble, isFalse, reason: 'the 1 is on the d4');
    // More than one kept d20: no single "natural" die.
    expect(roll('2d20', FixedRandom([20, 20])).isCritical, isFalse);
    expect(roll('1d20+1d20', FixedRandom([20, 3])).isCritical, isFalse);
    expect(roll('3d20kh2', FixedRandom([1, 1, 1])).isFumble, isFalse);
    expect(roll('5+3', FixedRandom([20])).isCritical, isFalse);
  });

  test('advantage and disadvantage only rewrite a single d20 roll', () {
    expect(withAdvantage('1d20'), '2d20kh1');
    expect(withAdvantage('d20+4'), '2d20kh1+4');
    expect(withAdvantage(' 1D20 + 4 − 1 '), '2d20kh1+4-1');
    expect(withAdvantage('1z20-2', disadvantage: true), '2d20kl1-2');
    expect(withAdvantage('3+1d20'), '3+2d20kh1');
    expect(withAdvantage(''), '2d20kh1', reason: 'an empty field means a plain d20');
    // Already rolled with (dis)advantage: the buttons switch between the two.
    expect(withAdvantage('2d20kh1+5', disadvantage: true), '2d20kl1+5');
    expect(withAdvantage('2d20kl1+5'), '2d20kh1+5');
    expect(withAdvantage('2d20k'), '2d20kh1');
    expect(withAdvantage('2d20dl1-1'), '2d20kh1-1');
    // Anything else is left alone.
    for (final e in ['2d6+3', '1d20+1d4', '2d20', '3d20kh1', '2d20kh2', '1d20*2', '5-1d20', '(1d20)+2', '1d20+', '1d12', '8', 'abc']) {
      expect(withAdvantage(e), isNull, reason: e);
      expect(withAdvantage(e, disadvantage: true), isNull, reason: e);
    }
  });

  test('random rolls stay within bounds', () {
    final rng = Random(42);
    for (var i = 0; i < 500; i++) {
      final v = roll('3d6+2', rng).total;
      expect(v, inInclusiveRange(5, 20));
    }
  });

  group('errors are reported in Turkish', () {
    for (final bad in ['', '2d', 'd1', '1001d6', '2d1001', '2d20kh3', '4d6dl4', '1d6dl', '2+', '(1d6', '3x', '1d6 2']) {
      test('"$bad"', () {
        expect(() => DiceExpression.parse(bad), throwsA(isA<DiceException>()));
      });
    }
    test('message', () {
      try {
        DiceExpression.parse('2d');
      } on DiceException catch (e) {
        expect(e.message, contains('yüz sayısı'));
      }
      expect(DiceExpression.isValid('2d20kh1+5'), isTrue);
      expect(() => roll('999999*999999*999999'), throwsA(isA<DiceException>()));
      expect(() => roll('1d6dl'), throwsA(predicate((e) => e is DiceException && e.message.contains('Tek zar'))));
    });
  });
}
