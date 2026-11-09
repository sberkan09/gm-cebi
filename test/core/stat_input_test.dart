import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/core/stat_input.dart';

void main() {
  test('parses short whole numbers only', () {
    expect(parseStat('12'), 12);
    expect(parseStat(' -3 '), -3);
    expect(parseStat('−2'), -2);
    expect(parseStat('9999'), 9999);
    expect(parseStat('12345'), isNull);
    expect(parseStat('12345678901234567890'), isNull); // used to throw
    expect(parseStat('1-2'), isNull);
    expect(parseStat('-'), isNull);
    expect(parseStat(''), isNull);
  });

  test('errors for optional fields', () {
    expect(statError(''), isNull);
    expect(statError('-4'), isNull);
    expect(statError('-'), 'Geçerli bir sayı yaz');
    expect(statError('1-2'), 'Geçerli bir sayı yaz');
    expect(statError('0', min: 1), 'En az 1');
    expect(statError('-1', min: 1), 'En az 1');
    expect(statError('1', min: 1), isNull);
  });
}
