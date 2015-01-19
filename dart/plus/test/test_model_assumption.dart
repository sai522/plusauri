library plus.test.test_model_assumption;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/date.dart';
import 'package:plus/repository.dart';
import 'package:plus/models/dossier.dart';

// end <additional imports>

// custom <library test_model_assumption>
// end <library test_model_assumption>
main() {
// custom <main>

  group('test_model_assumption.dart', () {
    var dossier = repository.dossiers.middleIncome;
    test('copy', () {
      var dossierCopy = dossier.copy();
      expect(dossier, dossierCopy);
      expect(identical(dossier.balanceSheet, dossierCopy.balanceSheet), false);

      // Change one field and ensure it is not shared
      expect(dossierCopy.personMap['johnDoe'].birthDate, date(1965,1,1));
      dossierCopy.personMap['johnDoe'] = null;
      expect(dossierCopy != dossier, true);
    });
  });

// end <main>

}
