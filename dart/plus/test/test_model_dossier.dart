library plus.test.test_model_dossier;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/repository.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/models/common.dart';

// end <additional imports>

// custom <library test_model_dossier>
// end <library test_model_dossier>
main() {
// custom <main>

  group('test_model_dossier.dart', () {

    final dossier = repository.dossiers.middleIncome;

    test('dossier toJson', () {
      final dossier2 = Dossier.fromJson(dossier.toJson());
      expect(dossier, dossier2);
    });

    test('user funding preferences', () {
      expect(dossier.expensePreferredLinks.length, 1);
      dossier.expensePreferredLinks.values.forEach(
          (List<HoldingKey> holdingKeys) {
        expect(
            holdingKeys.every((HoldingKey hk) => hk.accountName == 'college junior'),
            true);
      });
    });

    test('preferred expense sources', () {
      expect(dossier.preferredExpenseSources.length, 1);
      dossier.preferredExpenseSources.values.forEach(
          (List<HoldingKey> holdingKeys) =>
              expect(
                  holdingKeys.every((HoldingKey hk) => hk.accountName == 'college junior'),
                  true));
    });

  });

// end <main>

}

