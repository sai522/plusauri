library plus.test.test_model_balance_sheet;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu/ebisu_utils.dart';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/map_utilities.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/models/balance_sheet.dart';
import 'package:plus/finance.dart';
import 'package:plus/repository.dart';
import 'package:plus/test_utils.dart';

// end <additional imports>

// custom <library test_model_balance_sheet>
// end <library test_model_balance_sheet>
main() {
// custom <main>

  group('BalanceSheet FundingKeys', () {
    final dossier = repository.dossiers.middleIncome;
    final holdingKeys = dossier.balanceSheet.holdingKeys;
    test('Holding keys are cached', () {
      final holdingKeys2 = dossier.balanceSheet.holdingKeys;
      expect(holdingKeys, holdingKeys2);
      final it1 = holdingKeys.iterator;
      final it2 = holdingKeys2.iterator;
      for (int i = 0; i < holdingKeys.length; i++) {
        expect(identical(it1.current, it2.current), true);
        it1.moveNext();
        it2.moveNext();
      }
    });
  });

// end <main>

}
