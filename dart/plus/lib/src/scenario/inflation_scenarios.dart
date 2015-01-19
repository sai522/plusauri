part of plus.scenario;

class InflationGeometricShift
  implements ScenarioGenerator {
  const InflationGeometricShift(this._shift, this._shiftExpenses,
    this._shiftIncomes);

  double get shift => _shift;
  bool get shiftExpenses => _shiftExpenses;
  bool get shiftIncomes => _shiftIncomes;
  // custom <class InflationGeometricShift>

  AssumptionModel generateScenario(Dossier dossier,
                                   AssumptionModel assumptionModel) {
    final srcFlowModel = dossier.flowModel;
    final result = new AssumptionModelBuilder.copyFrom(assumptionModel);
    result.inflation = result.inflation * _shift;
    if(_shiftExpenses) {
      result.expenseModelOverrides = _updateExpenseMap(
          srcFlowModel.expenseModel, (rc) => rc * _shift);
    }
    if(_shiftIncomes) {
      result.incomeModelOverrides = _updateIncomeMap(
          srcFlowModel.incomeModel, (rc) => rc * _shift);    
    }
    return result.buildInstance();
  }

  // end <class InflationGeometricShift>
  final double _shift;
  final bool _shiftExpenses;
  final bool _shiftIncomes;
}

class InflationArithmeticShift
  implements ScenarioGenerator {
  const InflationArithmeticShift(this._shift, this._shiftExpenses,
    this._shiftIncomes);

  double get shift => _shift;
  bool get shiftExpenses => _shiftExpenses;
  bool get shiftIncomes => _shiftIncomes;
  // custom <class InflationArithmeticShift>

  AssumptionModel generateScenario(Dossier dossier,
                                   AssumptionModel assumptionModel) {
    final srcFlowModel = dossier.flowModel;
    final result = new AssumptionModelBuilder.copyFrom(assumptionModel);
    result.inflation = result.inflation + _shift;
    if(_shiftExpenses) {
      result.expenseModelOverrides = _updateExpenseMap(
          srcFlowModel.expenseModel, (rc) => rc + _shift);
    }
    if(_shiftIncomes) {
      result.incomeModelOverrides = _updateIncomeMap(
          srcFlowModel.incomeModel, (rc) => rc + _shift);    
    }
    return result.buildInstance();
  }

  // end <class InflationArithmeticShift>
  final double _shift;
  final bool _shiftExpenses;
  final bool _shiftIncomes;
}
// custom <part inflation_scenarios>

Map<String, ExpenseSpec> 
_updateExpenseMap(Map<String, ExpenseSpec> expenseModel,
                  CurveAdjuster curveAdjuster) =>
   valueApply(expenseModel, (es) {
    
    final originalFlowSpec = es.flowSpec;
    CFlowSequenceSpec cFlowSpec = 
        originalFlowSpec.cFlowSequenceSpec.copy();
    cFlowSpec.growth = curveAdjuster(cFlowSpec.growth);

    return new ExpenseSpec(es.expenseType,
                    new FlowSpec(originalFlowSpec.descr,
                        originalFlowSpec.source,   
                        cFlowSpec));
  });

Map<String, ExpenseSpec> 
_updateIncomeMap(Map<String, IncomeSpec> incomeModel,
                  CurveAdjuster curveAdjuster) =>
   valueApply(incomeModel, (incomeSpec) {
    
    final originalFlowSpec = incomeSpec.flowSpec;
    CFlowSequenceSpec cFlowSpec = 
        originalFlowSpec.cFlowSequenceSpec.copy();
    cFlowSpec.growth = curveAdjuster(cFlowSpec.growth);

    return new IncomeSpec(incomeSpec.incomeType,
                    new FlowSpec(originalFlowSpec.descr,
                        originalFlowSpec.source,   
                        cFlowSpec));
  });

// end <part inflation_scenarios>
