import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/logic/money.dart';

void main() {
  group('formatNaira', () {
    final cases = {
      0: '₦0',
      5: '₦0.05',
      50: '₦0.50',
      100: '₦1',
      250000: '₦2,500',
      125050: '₦1,250.50',
      99999: '₦999.99',
      100000: '₦1,000',
      99999999: '₦999,999.99',
      100000000: '₦1,000,000',
      -50000: '-₦500',
      -125050: '-₦1,250.50',
    };
    for (final MapEntry(key: kobo, value: text) in cases.entries) {
      test('$kobo kobo → $text', () => expect(formatNaira(kobo), text));
    }
  });

  group('parseNairaToKobo', () {
    final valid = {
      '0': 0,
      '0.00': 0,
      '0.01': 1,
      '2500': 250000,
      '2,500': 250000,
      '₦2,500': 250000,
      ' ₦ 1,250.50 ': 125050,
      '1250.5': 125050,
      '1,000,000': 100000000,
      '0012': 1200,
      '9999999999999': 999999999999900,
    };
    for (final MapEntry(key: text, value: kobo) in valid.entries) {
      test('"$text" → $kobo', () => expect(parseNairaToKobo(text), kobo));
    }

    final invalid = [
      '',
      '   ',
      '₦',
      'abc',
      '12a',
      '-5',
      '.5',
      '5.',
      '1.234',
      '1e3',
      '12,34',
      '1,2345',
      ',100',
      '1,000.',
      '1..0',
      '99999999999999',
    ];
    for (final text in invalid) {
      test('"$text" → null', () => expect(parseNairaToKobo(text), isNull));
    }

    test('round-trips with formatNaira', () {
      for (final kobo in [0, 1, 99, 100, 125050, 250000, 123456789]) {
        expect(parseNairaToKobo(formatNaira(kobo)), kobo);
      }
    });
  });

  group('formatNairaInput', () {
    final cases = {
      '': '',
      'abc': '',
      '0': '0',
      '00': '0',
      '2500': '2,500',
      '2,500': '2,500',
      '1234567': '1,234,567',
      '01250.505': '1,250.50',
      '.5': '0.5',
      '12.': '12.',
      '1.2.3': '1.23',
      '₦ 2500': '2,500',
      '99999999999999': '9,999,999,999,999',
    };
    for (final MapEntry(key: input, value: output) in cases.entries) {
      test('"$input" → "$output"', () {
        expect(formatNairaInput(input), output);
      });
    }

    test('its output always parses, except a trailing dot', () {
      for (final input in ['2500', '01250.505', '.5', '0']) {
        expect(parseNairaToKobo(formatNairaInput(input)), isNotNull);
      }
    });
  });
}
