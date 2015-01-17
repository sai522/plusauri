library plus.test.test_finance_cash_flow;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>

// custom <library test_finance_cash_flow>
// end <library test_finance_cash_flow>
main() {
// custom <main>

  group('test_finance_cash_flow.dart', () {

    group('cash_flow', () {
      var cf1 = cFlowSequence([
        dv(date(2001,1,1), 100.0),
        dv(date(2002,1,1), 200.0),
        dv(date(2003,1,1), 300.0),
        dv(date(2004,1,1), 400.0),
      ]);
      var rc1 = rateCurve([
        dv(date(1900,1,1), 0.03),
        dv(date(2002,1,1), 0.04),
      ]);
      var end = date(2000,1,1);

      test('straightSum', () {
        expect(cf1.straightSum, 1000.0);
      });

      test('valueOn', () {
        [ date(2000,1,1), date(2001,1,1), date(2001,6,1), date(2002,1,1) ]
          .forEach((end) {

            double actual = cf1.valueOn(end, rc1);
            double expected =
              moveValueInTime(100.0, 0.03, date(2001,1,1), end) +
              moveValueInTime(200.0, 0.03, date(2002,1,1), end) +
              (moveValueInTime(
                moveValueInTime(300.0, 0.04, date(2003,1,1), date(2002,1,1)),
                0.03, date(2002,1,1), end)) +
              (moveValueInTime(
                moveValueInTime(400.0, 0.04, date(2004,1,1), date(2002,1,1)),
                0.03, date(2002,1,1), end));

            expect(closeEnough(actual, expected), true);
          });

        [ date(2005,1,1), date(2006,1,1) ]
          .forEach((end) {

            double actual = cf1.valueOn(end, rc1);
            double expected =
              moveValueInTime(
                moveValueInTime(100.0, 0.03, date(2001,1,1), date(2002,1,1)),
                0.04, date(2002,1,1), end) +
              moveValueInTime(200.0, 0.04, date(2002,1,1), end) +
              moveValueInTime(300.0, 0.04, date(2003,1,1), end) +
              moveValueInTime(400.0, 0.04, date(2004,1,1), end);

            expect(closeEnough(actual, expected), true);
          });
      });

      test('valueOnFixedRate', () {
        var rc2 = rateCurve([ dv(date(100,1,1), 0.03) ]);
        [ date(1900,1,1), date(2001,1,1), date(2005,1,1), date(2010,1,1) ]
          .forEach((d) {
            double actual = cf1.valueOnFixedRate(d, 0.03);
            double expected = cf1.valueOn(d, rc2);
            expect(closeEnough(actual, expected), true);
          });
      });

    });
  });

// end <main>

}
