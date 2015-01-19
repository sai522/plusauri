part of timeline_forecast.timeline_model;

class GridTimelineModel
  implements ITimelineModel {
  GridTimelineModel(this._forecastGrid, this._inflation) { _init(); }

  ForecastGrid get forecastGrid => _forecastGrid;
  RateCurve get inflation => _inflation;
  ForecastBalances get netWorth => _netWorth;
  ForecastBalances get reserves => _reserves;
  ForecastBalances get netAssets => _netAssets;
  ForecastBalances get netLiabilities => _netLiabilities;
  ForecastFlows get netIncomes => _netIncomes;
  ForecastFlows get netExpenses => _netExpenses;
  ForecastFlows get netFlows => _netFlows;
  List<IAnnualForecastModel> get annualForecastsLazy => _annualForecastsLazy;
  // custom <class GridTimelineModel>

  DateRange get dateRange => _forecastGrid.dateRange;

  IAnnualForecastModel annualForecastModel(String label, int year) {
    return new GridAnnualForecastModel(_forecastGrid, label, year);
    // int index =  year - dateRange.start.year;
    // assert(index >= 0 && index < numYears);
    // if(_annualForecastsLazy[index] == null) {
    //   _annualForecastsLazy[index] =
    //     new GridAnnualForecastModel(_forecastGrid, label, year);
    // }
    // return _annualForecastsLazy[index];
  }

  int get numYears => _forecastGrid.numForecastYears;

  _init() {
    _initBalanceItems();
    _initFlowItems();
  }

  _initFlowItems() {
    int startYear = _forecastGrid.dateRange.start.year;
    int endYear = _forecastGrid.dateRange.end.year;

    final netIncomeFlows = new List<YearIncomeFlows>(endYear-startYear);
    final netExpenseFlows = new List<YearIncomeFlows>(endYear-startYear);
    final netFlows = new List<YearIncomeFlows>(endYear-startYear);

    for(int year = startYear; year < endYear; year++) {
      double netIncome = 0.0;
      double netExpense = 0.0;

      for(final incomeInfo in _forecastGrid.incomeInfos) {
        incomeInfo
          .flowsOnYearIterator(year)
          .forEach((FlowDetail flowDetail) {
            assert(flowDetail.flow > 0.0);
            netIncome += flowDetail.flow;
          });
      }

      for(final expenseInfo in _forecastGrid.expenseInfos) {
        expenseInfo
          .flowsOnYearIterator(year)
          .forEach((FlowDetail flowDetail) {
            assert(flowDetail.flow < 0.0);
            netExpense += -flowDetail.flow;
          });
      }

      netIncomeFlows[year-startYear] = new YearIncomeFlows()
        ..year = year..netFlow = netIncome;
      netExpenseFlows[year-startYear] = new YearIncomeFlows()
        ..year = year..netFlow = netExpense;
      netFlows[year-startYear] = new YearIncomeFlows()
        ..year = year..netFlow = netIncome - netExpense;
    }

    _netIncomes = new ForecastFlows('Net Inflows', netIncomeFlows)..findMinMax();
    _netExpenses = new ForecastFlows('Net Outflows', netExpenseFlows)..findMinMax();
    _netFlows = new ForecastFlows('Net Flows', netFlows)..findMinMax();
  }

  _initBalanceItems() {
    int years = numYears;
    _annualForecastsLazy = new List<IAnnualForecastModel>(years);
    List<PeriodBalance> netWorthPbs = new List<PeriodBalance>(years);
    List<PeriodBalance> reservesPbs = new List<PeriodBalance>(years);
    List<PeriodBalance> netAssetsPbs = new List<PeriodBalance>(years);
    List<PeriodBalance> netLiabilitiesPbs = new List<PeriodBalance>(years);
    int i=0;

    double prevNetAssets = 0.0, prevNetLiabilities = 0.0,
      prevNetWorth = 0.0, prevReserves = 0.0;

    _forecastGrid.visitPrepYear((GridYear gridYear) =>
      _gridTally(gridYear,
          (double netAssets, double netLiabilities, double netWorth, double reserves) {
        prevNetAssets = netAssets;
        prevNetLiabilities = netLiabilities;
        prevNetWorth = netWorth;
        prevReserves = reserves;
      }));

    _forecastGrid.visitGridYears((GridYear gridYear) {

      Date startDate = startOfYear(gridYear.year);
      Date endDate = gridYear.endDate;

      _gridTally(gridYear,
          (double netAssets, double netLiabilities, double netWorth, double reserves) {

        netWorthPbs[i] = new PeriodBalance.courtesy(
          dateValue(startDate, prevNetWorth),
          dateValue(endDate, netWorth));

        netAssetsPbs[i] = new PeriodBalance.courtesy(
          dateValue(startDate, prevNetAssets),
          dateValue(endDate, netAssets));

        netLiabilitiesPbs[i] = new PeriodBalance.courtesy(
          dateValue(startDate, prevNetLiabilities),
          dateValue(endDate, netLiabilities));

        reservesPbs[i] = new PeriodBalance.courtesy(
          dateValue(startDate, prevReserves),
          dateValue(endDate, reserves));

        prevNetAssets = netAssets;
        prevNetLiabilities = netLiabilities;
        prevNetWorth = netWorth;
        prevReserves = reserves;

      });

      i++;
    });

    _netWorth = new ForecastBalances('Net Worth', netWorthPbs);
    _netAssets = new ForecastBalances('Net Assets', netAssetsPbs);
    _netLiabilities = new ForecastBalances('Net Liabilities', netLiabilitiesPbs);
    _reserves = new ForecastBalances('Reserves', reservesPbs);
  }

  void _gridTally(GridYear gridYear, BalanceTally tally) {
    double netAssets = 0.0, netLiabilities = 0.0, netWorth = 0.0, reserves = 0.0;

    _forecastGrid.visitGridHoldings(gridYear,
        (HoldingInfo holdingInfo, GridHolding gridHolding) {
      final balance = gridHolding.balance;
      netAssets += balance;
      netWorth += balance;
    });

    _forecastGrid.visitGridAssets(gridYear,
        (AssetInfo assetInfo, GridBalance gridBalance) {
      final balance = gridBalance.balance;
      netAssets += balance;
      netWorth += balance;
    });

    _forecastGrid.visitGridLiabilities(gridYear,
        (LiabilityInfo liabilityInfo, GridBalance gridBalance) {
      final balance = gridBalance.balance;
      assert(balance >= 0.0);
      print('Liab balance ${gridYear.year} $balance');
      netWorth -= balance;
      netLiabilities -= balance;
    });

    reserves = gridYear.reserves.balance;
    //print('For year ${gridYear.year} reserves are $reserves');
    netWorth += reserves;

    tally(netAssets, netLiabilities, netWorth, reserves);
  }

  // end <class GridTimelineModel>
  final ForecastGrid _forecastGrid;
  final RateCurve _inflation;
  ForecastBalances _netWorth;
  ForecastBalances _reserves;
  ForecastBalances _netAssets;
  ForecastBalances _netLiabilities;
  ForecastFlows _netIncomes;
  ForecastFlows _netExpenses;
  ForecastFlows _netFlows;
  List<IAnnualForecastModel> _annualForecastsLazy;
}

class GridBalanceSheetModel
  implements IBalanceSheetModel {
  GridBalanceSheetModel(this._forecastGrid, this._gridYear) { _init(); }

  ForecastGrid get forecastGrid => _forecastGrid;
  GridYear get gridYear => _gridYear;
  // custom <class GridBalanceSheetModel>

  int get year => _gridYear.year;
  Date get startDate => _gridYear.startDate;
  Date get endDate => _gridYear.endDate;

  void visitAssets(BSMBalanceVisitor visitor) {
    _forecastGrid.visitGridAssets(_gridYear,
        (AssetInfo assetInfo, GridBalance gridBalance) {
      visitor(assetInfo.name, gridBalance.prevBalance, gridBalance.balance);
    });
  }

  void visitLiabilities(BSMBalanceVisitor visitor) {
    _forecastGrid.visitGridLiabilities(_gridYear,
        (LiabilityInfo LiabilityInfo, GridBalance gridBalance) {
      visitor(LiabilityInfo.name, gridBalance.prevBalance, gridBalance.balance);
    });
  }

  void visitAccounts(BSMAccountHoldingVisitor visitor) =>
    _forecastGrid.visitAccounts((AccountInfo accountInfo) =>
        visitor(accountInfo.accountName, accountInfo.numSymbolHoldings));

  void visitAccountOtherHoldings(String accountName, BSMHoldingValueVisitor visitor) {
    _forecastGrid.visitAccountOtherHoldings(_gridYear, accountName,
        (HoldingInfo holdingInfo, double startBalance, double endBalance) {
      visitor(holdingInfo.holdingKey, startBalance, endBalance);
    });
  }

  void visitAccountHoldings(String accountName, BSMHoldingValueVisitor visitor) {
    _forecastGrid.visitAccountHoldings(_gridYear, accountName,
        (HoldingInfo holdingInfo, double startBalance, double endBalance) {
      visitor(holdingInfo.holdingKey, startBalance, endBalance);
    });
  }

  void visitAccountTotalHoldings(String accountName,
      BSMHoldingValueVisitor visitor) {
    double totalStartValue = 0.0;
    double totalEndValue = 0.0;
    visitAccountOtherHoldings(accountName,
        (HoldingKey _, double startValue, double endValue) {
        totalStartValue += startValue;
        totalEndValue += endValue;
    });
    visitAccountHoldings(accountName,
        (HoldingKey _, double startValue, double endValue) {
      totalStartValue += startValue;
      totalEndValue += endValue;
    });

    visitor(new HoldingKey(accountName, '*'), totalStartValue, totalEndValue);
  }

  PeriodBalance get totalHoldings =>
    _fromGridBalance(_gridYear.totalHoldings);

  PeriodBalance get totalNonHoldingAssets =>
    _fromGridBalance(_gridYear.totalNonHoldingAssets);

  PeriodBalance get totalAssets =>
    _fromGridBalance(_gridYear.totalAssets);

  PeriodBalance get totalLiabilities {
    final result = _fromGridBalance(_gridYear.totalLiabilities);
    // This includes regular liabilites - but not extended liabilites
    // TODO: Add in extended liabilities
    return result;
  }

  PeriodBalance get reserves =>
    new PeriodBalance()
    ..start = new DateValue(_gridYear.startDate,
        _gridYear.reserves.prevBalance)
    ..end = new DateValue(_gridYear.endDate,
        _gridYear.reserves.balance);

  PeriodBalance _fromGridBalance(GridBalance gridBalance) =>
    new PeriodBalance.courtesy(
      dateValue(startDate, gridBalance.prevBalance),
      dateValue(endDate, gridBalance.balance));

  HoldingPeriodBalance createHoldingPeriodBalance(
    String accountName, String holdingName) =>
    _forecastGrid.createHoldingPeriodBalance(
      _gridYear, accountName, holdingName);

  HoldingPeriodBalance createAccountHoldingPeriodBalance(String accountName) =>
    _forecastGrid.createAccountHoldingPeriodBalance(_gridYear, accountName);

  HoldingPeriodBalance createTotalHoldingPeriodBalance() =>
    _forecastGrid.createTotalHoldingPeriodBalance(_gridYear);

  _init() {
  }

  // end <class GridBalanceSheetModel>
  final ForecastGrid _forecastGrid;
  final GridYear _gridYear;
}

class GridIncomeStatementModel
  implements IIncomeStatementModel {
  GridIncomeStatementModel(this._forecastGrid, this._year);

  ForecastGrid get forecastGrid => _forecastGrid;
  int get year => _year;
  // custom <class GridIncomeStatementModel>

  int get numIncomes => _forecastGrid.numIncomes;
  int get numExpenses => _forecastGrid.numExpenses;

  void visitIncomes(GridFlowVisitor visitor) =>
    _forecastGrid.visitIncomesOnYear(_year, visitor);

  void visitExpenses(GridFlowVisitor visitor) =>
    _forecastGrid.visitExpensesOnYear(_year, visitor);

  void visitObligatoryExpenses(GridFlowVisitor visitor) =>
    _forecastGrid.visitObligatoryExpensesOnYear(_year, visitor);

  void visitPVObligatoryExpenses(RateCurve discount, GridFlowVisitor visitor) =>
    _forecastGrid.visitPVObligatoryExpensesFromYear(_year, discount, visitor);

  // end <class GridIncomeStatementModel>
  final ForecastGrid _forecastGrid;
  final int _year;
}

class GridLiquidationSummaryModel
  implements ILiquidationSummaryModel {
  GridLiquidationSummaryModel(this._forecastGrid, this._gridYear) { _init(); }

  ForecastGrid get forecastGrid => _forecastGrid;
  GridYear get gridYear => _gridYear;
  // custom <class GridLiquidationSummaryModel>

  int get year => _gridYear.year;

  _init() {
    _gridYear.forecastDetails.flowAccountLinks
      .forEach((FlowAccountLink flowAccountLink) {
        final holdingKey = flowAccountLink.holdingKey;
        if(holdingKey == ReserveHolding) return;
        if(!_originalBalances.containsKey(holdingKey)) {
          final gridHolding = _forecastGrid.gridHolding(gridYear, holdingKey);
          _originalBalances[holdingKey] = gridHolding.netFullBalance;
          _originalNetTrade = gridHolding.netTrade;
        }
      });
  }

  void visitCredits(CreditVisitor creditVisitor) {
    final flowAccountLinks = _gridYear.forecastDetails.flowAccountLinks;
    flowAccountLinks
      .where((FlowAccountLink flowAccountLink) =>
          flowAccountLink.flowAllocation > 0.0)
      .forEach((FlowAccountLink flowAccountLink) {
        final flowDetail = flowAccountLink.flowDetail;
        final holdingKey = flowAccountLink.holdingKey;
        final flowAllocation = flowAccountLink.flowAllocation;
        final remainingBalance = holdingKey == ReserveHolding?
          (_originalNetTrade += flowAllocation) :
          (_originalBalances[holdingKey] += flowAllocation);
        creditVisitor(holdingKey,
            flowDetail == null? NetFlowsLabel : flowDetail.name,
            flowAccountLink.flowAllocation, remainingBalance);
      });
  }

  void visitDebits(DebitVisitor debitVisitor) {
    final flowAccountLinks = _gridYear.forecastDetails.flowAccountLinks;
    flowAccountLinks
      .where((FlowAccountLink flowAccountLink) => flowAccountLink.flowAllocation < 0.0)
      .forEach((FlowAccountLink flowAccountLink) {
        final flowDetail = flowAccountLink.flowDetail;
        final holdingKey = flowAccountLink.holdingKey;
        final flowAllocation = flowAccountLink.flowAllocation;
        final remainingBalance = holdingKey == ReserveHolding?
            (_originalNetTrade += flowAllocation) :
            (_originalBalances[holdingKey] += flowAllocation);
        debitVisitor(holdingKey,
            flowDetail == null? NetFlowsLabel : flowDetail.name,
            flowAllocation, remainingBalance);
      });
  }


  // end <class GridLiquidationSummaryModel>
  final ForecastGrid _forecastGrid;
  final GridYear _gridYear;
  Map<HoldingKey, double> _originalBalances = {};
  double _originalNetTrade = 0.0;
}

class GridTaxSummaryModel
  implements ITaxSummaryModel {
  GridYear get previousGridYear => _previousGridYear;
  GridYear get gridYear => _gridYear;
  DistributionBreakdown get shelteredDistributions => _shelteredDistributions;
  // custom <class GridTaxSummaryModel>

  GridTaxSummaryModel(this._previousGridYear, this._gridYear) {
    _shelteredDistributions = _gridYear.shelteredDistributions;
  }

  void visitPension(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.pension,
        _gridYear.taxBill.pension);

  void visitSocialSecurity(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.socialSecurity,
        _gridYear.taxBill.socialSecurity);

  void visitRental(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.rental,
        _gridYear.taxBill.rental);

  void visitLabor(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.labor,
        _gridYear.taxBill.labor);

  void visitCapitalGain(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.capitalGain,
        _gridYear.taxBill.capitalGain);

  void visitQualifiedDividends(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.qualifiedDividends,
        _gridYear.taxBill.qualifiedDividends);

  void visitUnqualifiedDividends(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.unqualifiedDividends,
        _gridYear.taxBill.unqualifiedDividends);

  void visitCapitalGainDistributions(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.capitalGainDistributions,
        _gridYear.taxBill.capitalGainDistributions);

  void visitInterest(TaxSummaryVisitor visitor) =>
    visitor(_previousGridYear.taxableIncomeBreakdown.interest,
        _gridYear.taxBill.interest);


  void visitShelteredCapitalGain(TaxSummaryVisitor visitor) =>
    visitor(_gridYear.shelteredCapitalGains, 0.0);
  void visitShelteredQualifiedDividends(TaxSummaryVisitor visitor) =>
    visitor(_shelteredDistributions.qualified, 0.0);
  void visitShelteredUnqualifiedDividends(TaxSummaryVisitor visitor) =>
    visitor(_shelteredDistributions.unqualified, 0.0);
  void visitShelteredCapitalGainDistributions(TaxSummaryVisitor visitor) =>
    visitor(_shelteredDistributions.capitalGainDistribution, 0.0);
  void visitShelteredInterest(TaxSummaryVisitor visitor) =>
    visitor(_shelteredDistributions.interest, 0.0);

  double get totalTaxes {
    double total = 0.0;
    void accumulator(double basis, double assessedTax) {
      total += assessedTax;
    }
    visitPension(accumulator);
    visitSocialSecurity(accumulator);
    visitRental(accumulator);
    visitLabor(accumulator);
    visitCapitalGain(accumulator);
    visitQualifiedDividends(accumulator);
    visitUnqualifiedDividends(accumulator);
    visitCapitalGainDistributions(accumulator);
    visitInterest(accumulator);
    return total;
  }



  // end <class GridTaxSummaryModel>
  final GridYear _previousGridYear;
  final GridYear _gridYear;
  DistributionBreakdown _shelteredDistributions;
}

class GridAnnualForecastModel
  implements IAnnualForecastModel {
  GridAnnualForecastModel(this._forecastGrid, this._title, this._year) { _init(); }

  ForecastGrid get forecastGrid => _forecastGrid;
  String get title => _title;
  int get year => _year;
  IBalanceSheetModel get balanceSheetModel => _balanceSheetModel;
  IIncomeStatementModel get incomeStatementModel => _incomeStatementModel;
  ILiquidationSummaryModel get liquidationSummaryModel => _liquidationSummaryModel;
  ITaxSummaryModel get taxSummaryModel => _taxSummaryModel;
  // custom <class GridAnnualForecastModel>

  _init() {
    final previousGridYear = _forecastGrid.gridYear(_year-1);
    final gridYear = _forecastGrid.gridYear(_year);
    _balanceSheetModel = new GridBalanceSheetModel(_forecastGrid, gridYear);
    _incomeStatementModel = new GridIncomeStatementModel(_forecastGrid, _year);
    _taxSummaryModel = new GridTaxSummaryModel(previousGridYear, gridYear);
    _liquidationSummaryModel = new GridLiquidationSummaryModel(_forecastGrid, gridYear);
  }

  // TODO: clean this up
  CurrentDollarsToggler _currentDollarsToggler = new CurrentDollarsToggler(today,
      new RateCurve([ dateValue(date(1900,1,1), 0.03) ]));
  CurrentDollarsToggler get currentDollarsToggler => _currentDollarsToggler;

  void visitExtendedLiabilities(RateCurve discount, AFVisitor visitor) {
    _balanceSheetModel.visitLiabilities((String liabilityName, double start, double end) {
      visitor(liabilityName, start, end, false);
    });

    Map<String, double> thisYear = {};
    Map<String, double> lastYear = {};

    _incomeStatementModel.visitPVObligatoryExpenses(discount,
        (String name, double amount) {
      thisYear[name] = amount;
    });

    final lastYearIncomeStatementModel =
      new GridIncomeStatementModel(_forecastGrid, _year - 1);

    lastYearIncomeStatementModel.visitPVObligatoryExpenses(discount,
        (String name, double amount) {
      lastYear[name] = amount;
    });

    thisYear.forEach((String liability, double expense) {
      final lastYearValue = lastYear[liability];
      visitor(liability, lastYearValue == null? 0.0 : -lastYearValue, -expense, true);
    });
  }

  // end <class GridAnnualForecastModel>
  final ForecastGrid _forecastGrid;
  final String _title;
  final int _year;
  IBalanceSheetModel _balanceSheetModel;
  IIncomeStatementModel _incomeStatementModel;
  ILiquidationSummaryModel _liquidationSummaryModel;
  ITaxSummaryModel _taxSummaryModel;
}
// custom <part grid_timeline>

typedef BalanceTally(double netAssets, double netLiabilities,
    double netWorth, double reserves);

const String NetFlowsLabel = '^Netted Flows';

// end <part grid_timeline>
