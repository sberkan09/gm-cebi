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

  test('random rolls stay within bounds', () {
    final rng = Random(42);
    for (var i = 0; i < 500; i++) {
      final v = roll('3d6+2', rng).total;
      expect(v, inInclusiveRange(5, 20));
    }
  });

  group('errors are reported in Turkish', () {
    for (final bad in ['', '2d', 'd1', '1001d6', '2d1001', '2d20kh3', '4d6dl4', '2+', '(1d6', '3x', '1d6 2']) {
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
    });
  });
}
