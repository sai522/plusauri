library plus.test.test_scenario;

import 'package:basic_input/formatting.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/date.dart';
import 'package:plus/repository.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/scenario.dart';

// end <additional imports>

// custom <library test_scenario>
// end <library test_scenario>
main() {
// custom <main>

  final dossier = repository.dossiers.middleIncome;
  final assumptionModel = dossier.assumptionModel;

  test('inflation geometric shift up', () {
    final inflationAssumptionModel = new InflationGeometricShift(
        1.5, true, true).generateScenario(dossier, assumptionModel);

    expect(assumptionModel.inflation * 1.5, inflationAssumptionModel.inflation);
    expect(assumptionModel.balanceSheetAssumptions,
        inflationAssumptionModel.balanceSheetAssumptions);
  });

  test('inflation geiometric shift down', () {
    final inflationAssumptionModel = new InflationGeometricShift(
        0.75, true, true).generateScenario(dossier, assumptionModel);

    expect(
        assumptionModel.inflation * 0.75, inflationAssumptionModel.inflation);
    expect(assumptionModel.balanceSheetAssumptions,
        inflationAssumptionModel.balanceSheetAssumptions);
  });

  test('inflation arithmetic shift up', () {
    final inflationAssumptionModel = new InflationArithmeticShift(
        1.5, true, true).generateScenario(dossier, assumptionModel);

    expect(assumptionModel.inflation + 1.5, inflationAssumptionModel.inflation);
    expect(assumptionModel.balanceSheetAssumptions,
        inflationAssumptionModel.balanceSheetAssumptions);
  });

  test('inflation geiometric shift down', () {
    final inflationAssumptionModel = new InflationArithmeticShift(
        -1.5, true, true).generateScenario(dossier, assumptionModel);

    expect(assumptionModel.inflation - 1.5, inflationAssumptionModel.inflation);
    expect(assumptionModel.balanceSheetAssumptions,
        inflationAssumptionModel.balanceSheetAssumptions);
  });

// end <main>

}
