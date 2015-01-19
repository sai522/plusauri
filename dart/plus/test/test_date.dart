library plus.test.test_date;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:plus/date.dart';
// end <additional imports>

// custom <library test_date>
// end <library test_date>
main() {
// custom <main>
  group('test_date.dart', () {
    group('general', () {
      test('basic operators', () {
        expect(new Date(2001, 1, 1), new Date(2001, 1, 1));
        expect(new Date(2001, 1, 1) == new Date(2002, 1, 1), false);
        expect(new Date(2001, 1, 1) == new Date(2001, 1, 1), true);
        expect(new Date(2001, 1, 1) < new Date(2002, 1, 1), true);
        expect(new Date(2001, 1, 1) <= new Date(2002, 1, 1), true);
        expect(new Date(2001, 1, 1) <= new Date(2001, 1, 1), true);
        expect(new Date(2001, 1, 1) > new Date(2001, 1, 1), false);
      });
      test('truncate to day', () {
        expect(
            new Date.fromDateTime(new DateTime.utc(1000, 1, 1, 23)),
            new Date(1000, 1, 1));
      });
      test('min date', () {
        expect(minDate(date(2001, 1, 1), date(2002, 1, 1)), date(2001, 1, 1));
        expect(minDate(date(2001, 1, 1), date(2001, 1, 1)), date(2001, 1, 1));
        expect(minDate(date(2002, 1, 1), date(2001, 1, 1)), date(2001, 1, 1));
      });
      test('max date', () {
        expect(maxDate(date(2001, 1, 1), date(2002, 1, 1)), date(2002, 1, 1));
        expect(maxDate(date(2001, 1, 1), date(2001, 1, 1)), date(2001, 1, 1));
        expect(maxDate(date(2002, 1, 1), date(2001, 1, 1)), date(2002, 1, 1));
      });
      test('nextDay/priorDay', () {
        expect(date(2001, 1, 1).nextDay, date(2001, 1, 2));
        expect(date(2001, 12, 31).nextDay, date(2002, 1, 1));
        expect(date(2001, 1, 31).nextDay, date(2001, 2, 1));

        expect(date(2001, 1, 1).priorDay, date(2000, 12, 31));
        expect(date(2001, 12, 31).priorDay, date(2001, 12, 30));
        expect(date(2001, 12, 1).priorDay, date(2001, 11, 30));
      });
      test('start/end of year', () {
        expect(date(2001, 1, 3).startOfYear, date(2001, 1, 1));
        expect(date(2001, 1, 3).endOfYear, date(2001, 12, 31));
      });
      test('startNextYear', () {
        expect(startOfNextYear(2001), date(2002, 1, 1));
      });
      test('json', () {
        expect(Date.fromJson(date(2001, 1, 1).toJson()), date(2001, 1, 1));
      });
      test('difference', () {
        expect(
            date(2001, 1, 1).difference(date(2000, 1, 1)),
            new Duration(days: 366));
        expect(
            date(2001, 1, 15).difference(date(2001, 1, 1)),
            new Duration(days: 14));
        expect(
            date(2001, 1, 1).difference(date(2001, 1, 1)),
            new Duration(days: 0));
      });
    });

    group('business functions', () {
      test('isLeapYear', () {
        expect(isLeapYear(1944), true);
        expect(isLeapYear(2000), true);
        expect(isLeapYear(2400), true);
        expect(isLeapYear(1800), false);
        expect(isLeapYear(1900), false);
        expect(isLeapYear(2100), false);
        expect(isLeapYear(2200), false);
        expect(isLeapYear(2300), false);
        expect(isLeapYear(1901), false);
        expect(isLeapYear(1902), false);
        expect(isLeapYear(1903), false);
      });

      test('endOfMonthCheck', () {
        expect(endOfMonthCheck(2000, 9, 31).day, 30);
        expect(endOfMonthCheck(2000, 2, 31).day, 29);
        expect(endOfMonthCheck(2001, 2, 31).day, 28);
        expect(endOfMonthCheck(2001, 1, 31).day, 31);
      });

      test('advanceDate', () {
        expect(
            advanceDate(Frequency.MONTHLY, date(2000, 12, 31)),
            date(2001, 1, 31));
        expect(
            advanceDate(Frequency.MONTHLY, date(2000, 1, 31)),
            date(2000, 2, 29));
        expect(
            advanceDate(Frequency.MONTHLY, date(2001, 1, 31)),
            date(2001, 2, 28));

      });
    });

    group('today', () {
      final t1 = today;
      final t2 = new Date.fromDateTime(new DateTime.now().toUtc());
      expect(t1, t2);
    });

  });

// end <main>

}

