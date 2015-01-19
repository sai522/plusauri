library plus.test.test_date_range;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/date_range.dart';
import 'package:plus/finance.dart';
import 'package:plus/test_utils.dart';
// end <additional imports>

// custom <library test_date_range>
// end <library test_date_range>
main() {
// custom <main>

  group('test_date_rage.dart', () {
    group('YearRange', () {
      final yearRange = new YearRange(2000, 2010);
      test('yearRange captures start/end', () {
        expect(yearRange.start, 2000);
        expect(yearRange.end, 2010);
        expect(
            yearRange.dateRange,
            dateRange(startOfYear(2000), startOfYear(2010)));
      });
    });
  });

  group('test_date_rage.dart', () {
    group('DateRange', () {
      test('accessors', () {
        var dr = dateRange(date(2001, 1, 1), date(2002, 1, 1));
        expect(dr.start, date(2001, 1, 1));
        expect(dr.end, date(2002, 1, 1));
      });
      test('start not after end', () {
        expect(
            () => dateRange(date(2003, 1, 1), date(2002, 1, 1)),
            throwsA(new isInstanceOf<ArgumentError>()));
      });
      test('copy produces equal', () {
        var dr = dateRange(date(2001, 1, 1), date(2002, 1, 1));
        var dr2 = dr.copy();
        expect(dr, dr2);
        // actual sharing is allowed since dates are immutable
        expect(identical(dr.start, dr2.start), true);
      });

    });

    group('IntervalDateRange', () {
      var idrRanges = intervalDateRange(
          date(2001, 1, 31),
          date(2004, 3, 1),
          Frequency.MONTHLY).dateRanges;

      expect(idrRanges[0], dateRange(date(2001, 1, 31), date(2001, 2, 28)));
      expect(idrRanges[1], dateRange(date(2001, 2, 28), date(2001, 3, 31)));
      expect(idrRanges[2], dateRange(date(2001, 3, 31), date(2001, 4, 30)));
      expect(idrRanges[3], dateRange(date(2001, 4, 30), date(2001, 5, 31)));
      expect(idrRanges[4], dateRange(date(2001, 5, 31), date(2001, 6, 30)));
      expect(idrRanges[5], dateRange(date(2001, 6, 30), date(2001, 7, 31)));
      expect(idrRanges[6], dateRange(date(2001, 7, 31), date(2001, 8, 31)));
      expect(idrRanges[7], dateRange(date(2001, 8, 31), date(2001, 9, 30)));
      expect(idrRanges[8], dateRange(date(2001, 9, 30), date(2001, 10, 31)));
      expect(idrRanges[9], dateRange(date(2001, 10, 31), date(2001, 11, 30)));
      expect(idrRanges[10], dateRange(date(2001, 11, 30), date(2001, 12, 31)));
      expect(idrRanges[11], dateRange(date(2001, 12, 31), date(2002, 1, 31)));


      expect(idrRanges[12], dateRange(date(2002, 1, 31), date(2002, 2, 28)));
      expect(idrRanges[13], dateRange(date(2002, 2, 28), date(2002, 3, 31)));
      expect(idrRanges[14], dateRange(date(2002, 3, 31), date(2002, 4, 30)));
      expect(idrRanges[15], dateRange(date(2002, 4, 30), date(2002, 5, 31)));
      expect(idrRanges[16], dateRange(date(2002, 5, 31), date(2002, 6, 30)));
      expect(idrRanges[17], dateRange(date(2002, 6, 30), date(2002, 7, 31)));
      expect(idrRanges[18], dateRange(date(2002, 7, 31), date(2002, 8, 31)));
      expect(idrRanges[19], dateRange(date(2002, 8, 31), date(2002, 9, 30)));
      expect(idrRanges[20], dateRange(date(2002, 9, 30), date(2002, 10, 31)));
      expect(idrRanges[21], dateRange(date(2002, 10, 31), date(2002, 11, 30)));
      expect(idrRanges[22], dateRange(date(2002, 11, 30), date(2002, 12, 31)));
      expect(idrRanges[23], dateRange(date(2002, 12, 31), date(2003, 1, 31)));

      expect(idrRanges[24], dateRange(date(2003, 1, 31), date(2003, 2, 28)));
      expect(idrRanges[25], dateRange(date(2003, 2, 28), date(2003, 3, 31)));
      expect(idrRanges[26], dateRange(date(2003, 3, 31), date(2003, 4, 30)));
      expect(idrRanges[27], dateRange(date(2003, 4, 30), date(2003, 5, 31)));
      expect(idrRanges[28], dateRange(date(2003, 5, 31), date(2003, 6, 30)));
      expect(idrRanges[29], dateRange(date(2003, 6, 30), date(2003, 7, 31)));
      expect(idrRanges[30], dateRange(date(2003, 7, 31), date(2003, 8, 31)));
      expect(idrRanges[31], dateRange(date(2003, 8, 31), date(2003, 9, 30)));
      expect(idrRanges[32], dateRange(date(2003, 9, 30), date(2003, 10, 31)));
      expect(idrRanges[33], dateRange(date(2003, 10, 31), date(2003, 11, 30)));
      expect(idrRanges[34], dateRange(date(2003, 11, 30), date(2003, 12, 31)));
      expect(idrRanges[35], dateRange(date(2003, 12, 31), date(2004, 1, 31)));

      expect(
          idrRanges[36],
          dateRange(date(2004, 1, 31), date(2004, 2, 29))); // leap
      expect(idrRanges[37], dateRange(date(2004, 2, 29), date(2004, 3, 1)));

      test('contains', () {
        expect(
            dateRange(date(2001, 1, 1), date(2010, 1, 1)).contains(date(2001, 1, 2)),
            true);

        expect(
            dateRange(date(2001, 1, 1), date(2010, 1, 1)).contains(date(2001, 1, 1)),
            true);

        expect(
            dateRange(date(2001, 1, 1), date(2010, 1, 1)).contains(date(2010, 1, 2)),
            false);

        expect(
            dateRange(date(2001, 1, 1), date(2010, 1, 1)).contains(date(2010, 1, 1)),
            false);

      });

      test('containsYear', () {
        expect(
            dateRange(date(2000, 1, 1), date(2010, 1, 1)).containsYear(2001),
            true);
        expect(
            dateRange(date(2001, 1, 1), date(2010, 1, 1)).containsYear(2001),
            true);
        expect(
            dateRange(date(2002, 1, 1), date(2010, 1, 1)).containsYear(2001),
            false);
        expect(
            dateRange(date(2000, 1, 1), date(2001, 1, 1)).containsYear(2001),
            false);
      });

      var dr1 = dateRange(date(2001, 1, 1), date(2010, 1, 1));
      var dr2 = dateRange(date(2001, 1, 1), date(2005, 1, 1));
      var dr3 = dateRange(date(2010, 1, 1), date(2011, 1, 1));
      var dr4 = dateRange(date(2009, 12, 31), date(2011, 1, 1));

      test('overlap', () {
        expect(overlap(dr1, dr1), true);
        expect(overlap(dr1, dr2), true);
        expect(overlap(dr2, dr1), true);
        expect(overlap(dr3, dr2), false);
        expect(overlap(dr2, dr3), false);
      });

      test('isStrictlyBefore', () {
        expect(dr1.isStrictlyBefore(dr2), false);
        expect(dr2.isStrictlyBefore(dr1), false);
        expect(dr1.isStrictlyBefore(dr3), true);
        expect(dr3.isStrictlyBefore(dr1), false);
        expect(dr1.isStrictlyBefore(dr4), false);
        expect(dr4.isStrictlyBefore(dr1), false);
      });

      test('oneDayRange', () {
        expect(
            oneDayRange(date(2001, 1, 1)),
            dateRange(date(2001, 1, 1), date(2001, 1, 2)));
      });

      test('subranges work monthly', () {
        var start = date(2001, 10, 31);
        var end = date(2004, 3, 1);
        var idr = intervalDateRange(start, end, Frequency.MONTHLY);
        idrRanges = idr.dateRanges;

        var rc = rateCurve([dv(date(1900, 1, 1), 0.03)]);
        var oneBigInterval = rc.scaleFromTo(start, end);
        var multipleIntervals = idrRanges.fold(
            1.0,
            (prev, range) => prev * rc.scaleFromTo(range.start, range.end));

        expect(closeEnough(oneBigInterval, multipleIntervals), true);
      });

      test('subranges work annually', () {
        var start = date(2001, 1, 1);
        var end = date(2020, 1, 1);
        var idr = intervalDateRange(start, end, ANNUAL);
        idrRanges = idr.dateRanges;

        var rc = rateCurve([dv(date(1900, 1, 1), 0.03)]);
        var oneBigInterval = rc.scaleFromTo(start, end);
        var multipleIntervals = idrRanges.fold(
            1.0,
            (prev, range) => prev * rc.scaleFromTo(range.start, range.end));

        expect(closeEnough(oneBigInterval, multipleIntervals), true);
      });

      test('fiscalRange should return SOY to SOY', () {
        expect(
            fiscalRange(1944),
            dateRange(date(1944, 1, 1), date(1945, 1, 1)));
      });

    });

  });

// end <main>

}
