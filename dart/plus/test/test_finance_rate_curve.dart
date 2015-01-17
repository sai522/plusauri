library plus.test.test_finance_rate_curve;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>

// custom <library test_finance_rate_curve>
// end <library test_finance_rate_curve>
main() {
// custom <main>

  group('test_finance_rate_curve.dart', () {
    group('RateCurve', () {
      var rc = rateCurve([ dv(date(1900,1,1), 1.0) ]);

      test('sorting', () {
        expect(new RateCurve([
          dv(date(2002,1,1), 2),
          dv(date(2001,1,1), 1),
        ]).curveData,
            [
              dv(date(2001,1,1), 1),
              dv(date(2002,1,1), 2)
            ]
               );

      });

      test('copy gives equal with no sharing', () {
        final copy = rc.copy();
        expect(rc, copy);
        expect(identical(rc.curveData, copy.curveData), false);
        expect(identical(rc.curveData.first, copy.curveData.first), false);
        copy.curveData[0].value *= 3;
        expect(rc != copy, true);
      });

      test('equality', () {
        expect(rateCurve([ dv(date(2001,1,1), 50) ]),
            rateCurve([ dv(date(2001,1,1), 50) ]));
        });
      test('hashCode', () {
        expect(rateCurve([ dv(date(2001,1,1), 50) ]).hashCode,
          rateCurve([ dv(date(2001,1,1), 50) ]).hashCode);
        });
      test('merge with empty', () {
        expect(RateCurve.merge(rc, rateCurve()), rc);
        expect(RateCurve.merge(rateCurve(), rc), rc);
      });
      test('merge with zero', () {
        var zero = rateCurve([ dv(date(1900,1,1), 0.0) ]);
        expect(RateCurve.merge(zero, rc), rc);
        expect(RateCurve.merge(rc, zero), rc);
      });
      test('merge with offseting curves', () {
        var offsetting = rc * -1;
        expect(RateCurve.merge(offsetting, rc), rateCurve());
      });
      test('merge with self doubles', () {
        expect(RateCurve.merge(rc, rc), rc*2.0);
      });
      test('merge sums rates', () {
        var rc1 = rateCurve( [
          dv(date(1900,1,1), 1.0),
          dv(date(2000,1,1), 2.0),
          dv(date(2001,1,1), 0.0),
        ]);

        var rc2 = rateCurve( [
          dv(date(1950,1,1), 1.0),
          dv(date(2000,1,1), 2.0),
          dv(date(2010,1,1), 2.0),
          dv(date(2011,1,1), 0.0),
          dv(date(2011,1,1), 0.0),
        ]);
        expect(RateCurve.merge(rc1, rc2),
            rateCurve([
              dv(date(1900,1,1), 1.0),
              dv(date(1950,1,1), 2.0),
              dv(date(2000,1,1), 4.0),
              dv(date(2001,1,1), 2.0),
              dv(date(2011,1,1), 0.0),
            ]));
      });

      var dvs = [
        dv(date(1950,1,1), 0.01),
        dv(date(2000,1,1), 0.02),
        dv(date(2010,1,1), 0.03),
        dv(date(2011,1,1), 0.04),
        dv(date(2011,3,2), 0.00),
      ];

      var rc2 = rateCurve(dvs);

      test('get rate', () {
        expect(rc2.getRate(date(1949,12,31)), 0.0);
        expect(rc2.getRate(date(1950,1,1)), 0.01);
        expect(rc2.getRate(date(1950,1,2)), 0.01);
        expect(rc2.getRate(date(2005,1,2)), 0.02);
        expect(rc2.getRate(date(2012,1,2)), 0.0);
        expect(rc2.getRate(date(2011,6,2)), 0.0);
        expect(rc2.getRate(date(2010,6,2)), 0.03);
      });

      test('revalueOn', () {
        expect(rc2.revalueOn(
              dateValue(date(1952,1,1), 1.0),
              date(1953,1,1)),
            rc2.scaleFromTo(date(1952,1,1), date(1953,1,1)));
      });

      test('scaleFromTo', () {
        expect(rc2.scaleFromTo(date(1940,1,1), date(1949,1,1)), 1.0);
        expect(rc2.scaleFromTo(date(1940,1,1), date(1950,1,1)), 1.0);
        expect(rc2.scaleFromTo(date(1940,1,1), date(1950,1,3)),
            exp(0.01*2.0/DaysPerYear));

        expect(rc2.scaleFromTo(date(2009,12,31), date(2011,1,2)),
            exp(0.02*1/DaysPerYear)*
            exp(0.03*365/DaysPerYear)*
            exp(0.04*1/DaysPerYear));

        expect(rc2.scaleFromTo(date(1000,1,1), date(3000,1,1)),
            exp(0.01*years(dvs[0].date, dvs[1].date))*
            exp(0.02*years(dvs[1].date, dvs[2].date))*
            exp(0.03*years(dvs[2].date, dvs[3].date))*
            exp(0.04*years(dvs[3].date, dvs[4].date)));
      });

      test('multiply and divide', () {
        expect(((rc2 * 2.0)/2.0), rc2);
      });

      var dvl = [
        dv(date(2000,1,1), 1.0),
        dv(date(2000,6,1), 2.0),
        dv(date(2001,1,1), 3.0),
        dv(date(2002,1,1), 4.0),
      ];

    });
  });

// end <main>

}
