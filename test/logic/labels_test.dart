import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/logic/labels.dart';

void main() {
  group('greetingFor uses the Lagos clock', () {
    final cases = {
      DateTime.utc(2026, 10, 9, 5): 'Good morning', // 06:00
      DateTime.utc(2026, 10, 9, 10, 59): 'Good morning', // 11:59
      DateTime.utc(2026, 10, 9, 11): 'Good afternoon', // 12:00
      DateTime.utc(2026, 10, 9, 15, 59): 'Good afternoon', // 16:59
      DateTime.utc(2026, 10, 9, 16): 'Good evening', // 17:00
      DateTime.utc(2026, 10, 9, 23): 'Good morning', // 00:00 next day
    };
    for (final MapEntry(key: now, value: greeting) in cases.entries) {
      test('$now → $greeting', () => expect(greetingFor(now), greeting));
    }
  });

  group('relativeDayLabel', () {
    final now = DateTime.utc(2026, 10, 9, 12); // Fri 9 Oct, Lagos

    test('same Lagos day is Today', () {
      expect(relativeDayLabel(DateTime.utc(2026, 10, 8, 23), now), 'Today');
    });

    test('previous Lagos day is Yesterday', () {
      expect(
        relativeDayLabel(DateTime.utc(2026, 10, 8, 22, 59), now),
        'Yesterday',
      );
    });

    test('older days show weekday, day and month', () {
      expect(relativeDayLabel(DateTime.utc(2026, 10, 5, 12), now), 'Mon 5 Oct');
    });

    test('just after Lagos midnight, the previous evening is Yesterday', () {
      final justAfterMidnight = DateTime.utc(2026, 10, 9, 23, 5);
      expect(
        relativeDayLabel(DateTime.utc(2026, 10, 9, 20), justAfterMidnight),
        'Yesterday',
      );
    });
  });

  test('weekdayShort', () {
    expect(weekdayShort(DateTime.utc(2026, 10, 5)), 'Mon');
    expect(weekdayShort(DateTime.utc(2026, 10, 11)), 'Sun');
  });

  group('initialsFor', () {
    test('two words', () => expect(initialsFor('Jane Ade'), 'JA'));
    test('one word', () => expect(initialsFor('jane'), 'J'));
    test('three words use the first two', () {
      expect(initialsFor('Ada Ngozi Obi'), 'AN');
    });
    test('extra spaces', () => expect(initialsFor('  Jane   Ade '), 'JA'));
    test('null or empty', () {
      expect(initialsFor(null), '');
      expect(initialsFor('   '), '');
    });
  });

  test('monthYearLabel uses the Lagos month', () {
    expect(monthYearLabel(DateTime.utc(2026, 10, 9, 12)), 'October 2026');
    // 31 Oct 23:30 UTC is 1 November in Lagos.
    expect(monthYearLabel(DateTime.utc(2026, 10, 31, 23, 30)), 'November 2026');
  });

  group('dayPhrase', () {
    final now = DateTime.utc(2026, 10, 9, 12); // Fri 9 Oct
    test('today and yesterday', () {
      expect(dayPhrase(DateTime.utc(2026, 10, 9, 8), now), 'today');
      expect(dayPhrase(DateTime.utc(2026, 10, 8, 8), now), 'yesterday');
    });
    test('this week uses the weekday', () {
      expect(dayPhrase(DateTime.utc(2026, 10, 6, 8), now), 'on Tuesday');
      expect(dayPhrase(DateTime.utc(2026, 10, 3, 8), now), 'on Saturday');
    });
    test('older uses the date', () {
      expect(dayPhrase(DateTime.utc(2026, 10, 2, 8), now), 'on 2 Oct');
    });
  });

  test('dateRowLabel', () {
    final now = DateTime.utc(2026, 10, 9, 12);
    expect(dateRowLabel(DateTime.utc(2026, 10, 9), now), 'Today');
    expect(dateRowLabel(DateTime.utc(2026, 10, 8), now), 'Yesterday');
    expect(dateRowLabel(DateTime.utc(2026, 10, 5), now), 'Mon 5 Oct');
  });
}
