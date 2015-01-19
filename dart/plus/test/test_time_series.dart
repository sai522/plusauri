library plus.test.test_time_series;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/time_series.dart';
import 'package:plus/finance.dart';

// end <additional imports>

// custom <library test_time_series>
// end <library test_time_series>
main() {
	// custom <main>

	group('../test/test_time_series.dart', () {

          test('out_of_order', () {
            var ts;
            try {
              ts = timeSeries([
                dateValue(date(2001,2,1), 2.0),
                dateValue(date(2001,1,1), 1.0),
              ]);
              if(ts != null) expect(ts.isOrdered, false);
            } on AssertionError catch(e) {
              // In debug expected exception out of order
            }
          });

          var ts = timeSeries([
            dateValue(date(2001,1,1), 1.0),
            dateValue(date(2001,2,1), 2.0),
            dateValue(date(2001,3,1), 3.0),
          ]);

          test('filterOnRange', () {
            expect(ts.filterOnRange(
                  dateRange(date(2000,1,1), date(2001,1,1))).toList(),
                []);
            expect(ts.filterOnRange(
                  dateRange(date(2000,1,1), date(2001,1,2))).toList(),
                [dateValue(date(2001,1,1), 1.0)]);
          });

          test('copy produces equal with no sharing', () {
            final ts2 = ts.copy();
            expect(ts, ts2);
            expect(identical(ts.data[0], ts2.data[0]), false);
          });

          test('firstOnOrBefore', () {
            expect(ts.firstOnOrBefore(date(1000,1,1)), null);
            expect(ts.firstOnOrBefore(date(2001,1,1)), dateValue(date(2001,1,1), 1.0));
            expect(ts.firstOnOrBefore(date(2001,1,2)), dateValue(date(2001,1,1), 1.0));
            expect(ts.firstOnOrBefore(date(2001,2,1)), dateValue(date(2001,2,1), 2.0));
            expect(ts.firstOnOrBefore(date(2001,2,2)), dateValue(date(2001,2,1), 2.0));
            expect(ts.firstOnOrBefore(date(3001,1,1)), dateValue(date(2001,3,1), 3.0));
          });

          test('filterOnYear', () {
            expect(ts.filterOnYear(2000).toList(), []);
            expect(ts.filterOnYear(2002).toList(), []);
            expect(ts.filterOnYear(2001).toList(),
                [
                  dateValue(date(2001,1,1), 1.0),
                  dateValue(date(2001,2,1), 2.0),
                  dateValue(date(2001,3,1), 3.0)
                ]);
          });

          test('sumToDateOnCurve', () {
            final curve = new RateCurve([ dateValue(date(1900,1,1), 0.03) ]);
            expect(ts.sumToDateOnCurve(date(2004,1,1), ZeroRateCurve), ts.sum);
            expect(ts.sumToDateOnCurve(date(2004,1,1), curve),
                curve.revalueOn(ts.firstOnOrBefore(date(2001,1,1)), date(2004,1,1)) +
                curve.revalueOn(ts.firstOnOrBefore(date(2001,2,1)), date(2004,1,1)) +
                curve.revalueOn(ts.firstOnOrBefore(date(2001,3,1)), date(2004,1,1)));
          });

          test('splice', () {
            var ts_x_3 = splice(splice(ts, ts), ts);
            expect(ts_x_3[0], ts[0]);
            expect(ts_x_3[1], ts[0]);
            expect(ts_x_3[2], ts[0]);

            expect(ts_x_3[3], ts[1]);
            expect(ts_x_3[4], ts[1]);
            expect(ts_x_3[5], ts[1]);

            expect(ts_x_3[6], ts[2]);
            expect(ts_x_3[7], ts[2]);
            expect(ts_x_3[8], ts[2]);
          });

          test('json', () {
            expect(TimeSeries.fromJson(ts.toJson()), ts);
          });
        });

	// end <main>

}
