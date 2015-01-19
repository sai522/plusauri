part of plus.repository;

// custom <part dossiers>

class _Dossiers {

  static _createInstrumentAssumptions(holdingReturns, [instrumentPartitions]) {
    final result = new InstrumentAssumptions(HoldingType.STOCK, holdingReturns, instrumentPartitions == null ? DefaultSingleStockPartitions : instrumentPartitions);
    return result;
  }

  static get _ibmAssumptions => _createInstrumentAssumptions(new HoldingReturns({
    HoldingReturnType.CAPITAL_APPRECIATION: _curves.stockReturn,
    HoldingReturnType.QUALIFIED_DIVIDEND: _curves.qualifiedDivReturn,
    HoldingReturnType.UNQUALIFIED_DIVIDEND: _curves.unqualifiedDivReturn,
  }));

  static get _ibmDripAssumptions => _createInstrumentAssumptions(new HoldingReturns({
    HoldingReturnType.CAPITAL_APPRECIATION: _curves.stockReturn,
    HoldingReturnType.QUALIFIED_DIVIDEND: _curves.qualifiedDivReturn,
    HoldingReturnType.UNQUALIFIED_DIVIDEND: _curves.unqualifiedDivReturn,
  }));

  static get _msftAssumptions => _createInstrumentAssumptions(new HoldingReturns({
    HoldingReturnType.CAPITAL_APPRECIATION: RateCurve.merge(_curves.stockReturn, _curves.unqualifiedDivReturn),
    HoldingReturnType.QUALIFIED_DIVIDEND: _curves.qualifiedDivReturn,
  }));

  static get _msftQdripAssumptions => _createInstrumentAssumptions(new HoldingReturns({
    HoldingReturnType.CAPITAL_APPRECIATION: RateCurve.merge(_curves.stockReturn, _curves.unqualifiedDivReturn),
    HoldingReturnType.QUALIFIED_DIVIDEND: _curves.qualifiedDivReturn,
  }));

  static get _nodivAssumptions => _createInstrumentAssumptions(new HoldingReturns({
    HoldingReturnType.CAPITAL_APPRECIATION: RateCurve.merge(RateCurve.merge(_curves.stockReturn, _curves.qualifiedDivReturn), _curves.unqualifiedDivReturn)
  }));

  get middleIncome {
    var result = (new DossierBuilder()
        ..id = 'The Middle Income Family'
        ..personMap = _people.all
        ..flowModel = _flowModels.middleIncome
        ..balanceSheet = _balanceSheets.typical
        ..assumptionModel = new AssumptionModel(_curves.inflation,
            new BalanceSheetAssumptions(
              // Asset Assumptions
              {
                'fiveFourAndADoor': _curves.inflation,
                'caymanPorsche': _curves.caymanPorsche,
              },
              // Liability Assumptions
              {
                'collegeEducationPurchase': _curves.stateCollegeCostIncreases,
              },
              // Account Assumptions
              {
                'etrade': new AccountAssumptions(
                  _ibmAssumptions, // defaultInstrumentAssumptions
                  null, // defaultReinvestmentPolicy
                  // HoldingReinvestmentPolicies
                  {
                    'ibm' : ReinvestForCashFlow,
                    'msft' : ReinvestForCashFlow,
                  })
              },
              // InstrumentAssumptions
              {
                'ibm': _ibmAssumptions,
                'ibmDrip': _ibmDripAssumptions,
                'msft': _msftAssumptions,
                'msftQdrip': _msftQdripAssumptions,
                'nodiv': _nodivAssumptions
              }),
            {},
            {},
            {},
            DefaultStrategyAssumptions,
            DefaultTaxRateAssumptions,
            DefaultReserveAssumptions)
        ..fundingLinks = {'economicChildCollege' : 'college junior' }
        ..investmentLinks = {});

    return result.buildInstance();
  }

  get all => {
    'middleIncome': middleIncome,
  };
}

var _dossiers = new _Dossiers();

// end <part dossiers>
