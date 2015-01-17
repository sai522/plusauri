library plus.test.test_finance_tvm;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>

// custom <library test_finance_tvm>
// end <library test_finance_tvm>
main() {
// custom <main>

  group('test_finance_tvm.dart', () {

    group('ccRate', () {
      final d1 = date(2000,1,1);
      final d2 = date(2010,1,1);
      expect(ccRate(dateValue(d1, 1.0), dateValue(d2, 1.25)),
          log(1.25)/years(d1, d2));
    });

    group('ccToAnnual', () {
      expect(ccToAnnual(.03) > .03, true);
      expect(ccToAnnual(.03), exp(.03)-1.0);
    });

    expect(print('TODO: test years function'), null);
    group('daysBetween', () {
      test('daysBetween', () {
        expect(print('TODO: test daysBetween'), null);
      });
    });

    group('moveValueInTime', () {
      test('move forward in time', () {
        expect(moveValueInTime(1.0, 0.05, date(2001,1,1), date(2001,1,2)),
            exp(0.05 * 1/DaysPerYear));
        expect(moveValueInTime(1.0, 0.05, date(2001,1,1), date(2003,1,2)),
            exp(0.05 * (731.0)/DaysPerYear));
      });

      test('move back in time', () {
        expect(moveValueInTime(1.0, 0.05, date(2001,1,2), date(2001,1,1)),
            exp(-0.05 * 1/DaysPerYear));
        expect(moveValueInTime(1.0, 0.05, date(2003,1,2), date(2001,1,1)),
            exp(-0.05 * (731.0)/DaysPerYear));
      });

    });
  });

// end <main>

}
