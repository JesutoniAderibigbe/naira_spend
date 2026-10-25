import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/logic/expense_validation.dart';

void main() {
  group('validateAmount', () {
    test('empty', () => expect(validateAmount('  '), 'Enter an amount'));
    test('zero', () {
      expect(validateAmount('0'), 'Amount must be more than ₦0');
      expect(validateAmount('0.00'), 'Amount must be more than ₦0');
    });
    test('invalid', () {
      expect(validateAmount('abc'), 'Enter an amount like 2,500 or 1,250.50');
      expect(validateAmount('1.234'), isNotNull);
    });
    test('valid', () {
      expect(validateAmount('2,500'), isNull);
      expect(validateAmount('0.01'), isNull);
      expect(validateAmount('1,250.50'), isNull);
    });
  });

  group('validateTitle', () {
    test('empty', () => expect(validateTitle('   '), 'Say what you bought'));
    test('exactly 60 characters is fine', () {
      expect(validateTitle('a' * 60), isNull);
    });
    test('61 characters is too long', () {
      expect(validateTitle('a' * 61), 'Keep it under 60 characters');
    });
    test('surrounding spaces are ignored', () {
      expect(validateTitle('  Suya  '), isNull);
    });
  });

  group('validateDay', () {
    // Friday 9 October 2026, 23:30 in Lagos.
    final now = DateTime.utc(2026, 10, 9, 22, 30);

    test('today is fine', () {
      expect(validateDay(DateTime.utc(2026, 10, 9), now), isNull);
    });
    test('the past is fine', () {
      expect(validateDay(DateTime.utc(2025, 1, 1), now), isNull);
    });
    test('tomorrow in Lagos is not', () {
      expect(
        validateDay(DateTime.utc(2026, 10, 10), now),
        "The date can't be in the future",
      );
    });
  });
}
