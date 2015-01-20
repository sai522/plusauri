library plus.test.test_finance_mortgage;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>

// custom <library test_finance_mortgage>
// end <library test_finance_mortgage>
main() {
// custom <main>

  group('test_finance_mortgage.dart', () {
    test('mortgagePayment', () {
      expect(
          closeEnough(mortgagePayment(1000000, 0.05, 30), 5368.2162301213975),
          true);
    });

    var x = new MortgageSpec(165000.0, 0.50, 30.0);

    expect(print('TODO: test paymentSchedule'), null);

    x.paymentSchedule(new DateTime(2001, 1, 1)).forEach((rec) {
      //    print("Record => ${pp(rec)}");
    });
  });

// end <main>

}
