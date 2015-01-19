part of plus.scenario;

class ReturnGeometricShift
  implements ScenarioGenerator {
  ReturnGeometricShift(this.shift);

  double shift = 1.0;
  // custom <class ReturnGeometricShift>

  AssumptionModel generateScenario(Dossier _,
                                   AssumptionModel assumptionModel) {
    //    print("Pre shift of $shift: ${assumptionModel.balanceSheetAssumptions.instrumentAssumptions}");
    final result = (new AssumptionModelBuilder.copyFrom(assumptionModel
        )..balanceSheetAssumptions = _visitBalanceSheetCurves(
        assumptionModel.balanceSheetAssumptions, (RateCurve curve) => curve * shift
        )).buildInstance();
    //    print("Post shift of $shift: ${result.balanceSheetAssumptions.instrumentAssumptions}");
    return result;
  }

  // end <class ReturnGeometricShift>
}

class ReturnArithmeticShift
  implements ScenarioGenerator {
  ReturnArithmeticShift(this.shift);

  double shift = 1.0;
  // custom <class ReturnArithmeticShift>


  AssumptionModel generateScenario(Dossier _,
                                   AssumptionModel assumptionModel) {
    final result = (new AssumptionModelBuilder.copyFrom(assumptionModel
        )..balanceSheetAssumptions = _visitBalanceSheetCurves(
        assumptionModel.balanceSheetAssumptions, (RateCurve curve) => curve + shift
        )).buildInstance();
    return result;
  }

  // end <class ReturnArithmeticShift>
}

class ReturnUnfavorableSequence
  implements ScenarioGenerator {
  ReturnUnfavorableSequence(this.shift);

  double shift = 1.0;
  // custom <class ReturnUnfavorableSequence>

  AssumptionModel generateScenario(Dossier _,
                                   AssumptionModel assumptionModel) => null;

  // end <class ReturnUnfavorableSequence>
}

class ReturnFavorableSequence
  implements ScenarioGenerator {
  ReturnFavorableSequence(this.shift);

  double shift = 1.0;
  // custom <class ReturnFavorableSequence>

  AssumptionModel generateScenario(Dossier _,
                                   AssumptionModel assumptionModel) => null;

  // end <class ReturnFavorableSequence>
}
// custom <part asset_return_scenarios>


_visitBalanceSheetCurves(BalanceSheetAssumptions assumptions, CurveAdjuster
    curveAdjuster) {
  var builder = new BalanceSheetAssumptionsBuilder.copyFrom(assumptions);

  builder.accountAssumptions = valueApply(builder.accountAssumptions,
      (AccountAssumptions accountAssumptions) =>
      accountAssumptions.copyWithCurveAdjustment(curveAdjuster));

  var pre = builder.instrumentAssumptions;
  builder.instrumentAssumptions = valueApply(builder.instrumentAssumptions,
      (InstrumentAssumptions source) =>
      source.adjustHoldingReturnCurves(curveAdjuster));

  assert(pre != builder.instrumentAssumptions);

  builder.assetAssumptions = valueApply(builder.assetAssumptions,
      (RateCurve curve) => curveAdjuster(curve));

  return builder.buildInstance();
}

// end <part asset_return_scenarios>
