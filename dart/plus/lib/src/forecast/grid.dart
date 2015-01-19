part of plus.forecast;

class ForecastGrid {
  /// Date range where the first year precedes the year of the forecast
  DateRange get completeDateRange => _completeDateRange;
  DateRange get dateRange => _dateRange;
  List<IncomeInfo> get incomeInfos => _incomeInfos;
  List<ExpenseInfo> get expenseInfos => _expenseInfos;
  // custom <class ForecastGrid>

  ForecastGrid.fromDossier(this._dossier, YearRange requestedYearRange,
      {AssumptionModel assumptionModelOverride, bool trackDetails: false}) {
    _trackDetails = trackDetails;
    _dateRange = requestedYearRange.dateRange;
    _completeYearRange =
        new YearRange(requestedYearRange.start - 1, requestedYearRange.end);
    _completeDateRange = _completeYearRange.dateRange;
    _initializeAssumptions(assumptionModelOverride);
    _initializeBalanceSheetItems();
    _initializeGrid();
    _initializeFlows();
    _initializeLinkPreferences();
    _initializeReserveRates();
    _forecastGrid();
  }

  int get numAssets => _assetInfos.length;
  int get numLiabilities => _liabilityInfos.length;
  int get numHoldings => _holdingInfos.length;
  int get numIncomes => _incomeInfos.length;
  int get numExpenses => _expenseInfos.length;
  int get numForecastYears => _gridYears.length - 1;

  GridYear gridYear(int year) => _gridYears[year - _completeYearRange.start];

  GridHolding gridHolding(GridYear gridYear, HoldingKey holdingKey) =>
      gridYear.gridHoldings[_matchingGridHolding(holdingKey)];

  void visitPrepYear(GridYearVisitor visitor) => visitor(_gridYears[0]);

  void visitGridYears(GridYearVisitor visitor) {
    final numYears = _completeYearRange.years;
    for (int i = 1; i < numYears; i++) {
      visitor(_gridYears[i]);
    }
  }

  void visitIncomesOnYear(int year, GridFlowVisitor visitor) {
    _incomeInfos.forEach((IncomeInfo incomeInfo) {
      double sum = incomeInfo.flowsOnYearIterator(
          year).fold(0.0, (double sum, FlowDetail flowDetail) => flowDetail.flow + sum);
      visitor(incomeInfo.name, sum);
    });
    final gridYear = this.gridYear(year);
    for (final flowDetail in gridYear.standardIncomeFlowDetails) {
      visitor(flowDetail.name, flowDetail.flow);
    }
  }

  void visitObligatoryExpensesOnYear(int year, GridFlowVisitor visitor) {
    _expenseInfos.where(
        (ExpenseInfo expenseInfo) =>
            expenseInfo.expenseType.isObligatory).forEach((ExpenseInfo expenseInfo) {
      double sum = expenseInfo.flowsOnYearIterator(
          year).fold(0.0, (double sum, FlowDetail flowDetail) => flowDetail.flow + sum);
      visitor(expenseInfo.name, sum);
    });
  }

  void visitPVObligatoryExpensesFromYear(int year, RateCurve discount,
      GridFlowVisitor visitor) {
    _expenseInfos.where(
        (ExpenseInfo expenseInfo) =>
            expenseInfo.expenseType.isObligatory).forEach((ExpenseInfo expenseInfo) {
      double sum = expenseInfo.pvFromYear(year, discount);
      visitor(expenseInfo.name, sum);
    });
  }

  void visitExpensesOnYear(int year, GridFlowVisitor visitor) {
    _expenseInfos.forEach((ExpenseInfo expenseInfo) {
      double sum = expenseInfo.flowsOnYearIterator(
          year).fold(0.0, (double sum, FlowDetail flowDetail) => flowDetail.flow + sum);
      visitor(expenseInfo.name, sum);
    });
    final gridYear = this.gridYear(year);
    for (final flowDetail in gridYear.standardExpenseFlowDetails) {
      visitor(flowDetail.name, flowDetail.flow);
    }
  }

  void visitAccounts(GridAccountVisitor visitor) =>
      _accountInfos.forEach((AccountInfo accountInfo) => visitor(accountInfo));

  void visitAccountOtherHoldings(GridYear gridYear, String accountName,
      GridHoldingValueVisitor visitor) {
    final accountInfo = _accountInfos.firstWhere(
        (AccountInfo accountInfo) => accountInfo.accountName == accountName);
    for (int i = accountInfo.startIndex; i < accountInfo.endIndex; i++) {
      final holdingInfo = _holdingInfos[i];
      if (holdingInfo.accountName == accountName &&
          holdingInfo.holdingName == GeneralAccount) {
        final gridHolding = gridYear.gridHoldings[i];
        visitor(holdingInfo, gridHolding.prevBalance, gridHolding.balance);
        return;
      }
    }
  }

  void visitAccountHoldings(GridYear gridYear, String accountName,
      GridHoldingValueVisitor visitor) {
    final accountInfo = _accountInfos.firstWhere(
        (AccountInfo accountInfo) => accountInfo.accountName == accountName);
    for (int i = accountInfo.startIndex; i < accountInfo.endIndex; i++) {
      final holdingInfo = _holdingInfos[i];
      if (holdingInfo.accountName == accountName &&
          holdingInfo.holdingName != GeneralAccount) {
        final gridHolding = gridYear.gridHoldings[i];
        visitor(holdingInfo, gridHolding.prevBalance, gridHolding.balance);
      }
    }
  }

  void visitGridHoldings(GridYear gridYear, GridHoldingVisitor visitor) {
    final numHoldings = this.numHoldings;
    for (int i = 0; i < numHoldings; i++) {
      visitor(_holdingInfos[i], gridYear.gridHoldings[i]);
    }
  }

  void visitGridAssets(GridYear gridYear, GridAssetVisitor visitor) {
    final numAssets = this.numAssets;
    for (int i = 0; i < numAssets; i++) {
      visitor(_assetInfos[i], gridYear.assetBalances[i]);
    }
  }

  void visitGridLiabilities(GridYear gridYear, GridLiabilityVisitor visitor) {
    final numLiabilities = this.numLiabilities;
    for (int i = 0; i < numLiabilities; i++) {
      visitor(_liabilityInfos[i], gridYear.liabilityBalances[i]);
    }
  }

  int _findAccountStartIndex(String accountName) =>
      _accountInfos.firstWhere(
          (AccountInfo accountInfo) => accountInfo.accountName == accountName).startIndex;

  int _findHoldingInfoIndex(String accountName, String holdingName) {
    final startIndex = _findAccountStartIndex(accountName);
    return startIndex +
        _holdingInfos.skip(
            startIndex).takeWhile(
                (HoldingInfo holdingInfo) => holdingInfo.holdingName != holdingName).length;
  }

  HoldingPeriodBalance createHoldingPeriodBalance(GridYear gridYear,
      String accountName, String holdingName) =>
      _createHoldingPeriodBalance(
          gridYear,
          _findHoldingInfoIndex(accountName, holdingName));

  HoldingPeriodBalance _createHoldingPeriodBalance(GridYear gridYear,
      int index) {
    HoldingPeriodBalance result;
    final holdingInfo = _holdingInfos[index];
    final holding = holdingInfo.holding;
    final gridHolding = gridYear.gridHoldings[index];
    final periodBalance = new PeriodBalance.courtesy(
        dateValue(gridYear.startDate, gridHolding.prevBalance),
        dateValue(gridYear.endDate, gridHolding.balance));
    final instrumentPartitionMappings =
        new InstrumentPartitionMappings.fromAssumptions(
            periodBalance.endValue,
            holdingInfo.instrumentPartitions);

    final distributionSummary = new DistributionSummary(
        gridHolding.distributedDistributions,
        gridHolding.reinvestedDistributions);

    final avgCostAccumulator = gridHolding.avgCostAccumulator;

    final prevYear = this.gridYear(gridYear.year - 1);
    final prevHolding = prevYear.gridHoldings[index];
    final prevAvgCostAccumulator = prevHolding.avgCostAccumulator;






        //print('HPB ${gridYear.year} capGain ${gridHolding.unshelteredCapitalGain}');

    result = new HoldingPeriodBalance(
        holding.holdingType,
        periodBalance,
        distributionSummary,
        new PeriodBalance.courtesy(
            dateValue(gridYear.startDate, prevAvgCostAccumulator.totalCost),
            dateValue(gridYear.endDate, avgCostAccumulator.totalCost)),
        gridHolding.unshelteredCapitalGain,
        instrumentPartitionMappings,
        gridHolding.growthDetails,
        gridHolding.netTrade);

    return result;
  }

  HoldingPeriodBalance createAccountHoldingPeriodBalance(GridYear gridYear,
      String accountName) {
    final accountInfo = _accountInfos.firstWhere(
        (AccountInfo accountInfo) => accountInfo.accountName == accountName);
    final startIndex = accountInfo.startIndex;
    final endIndex = accountInfo.endIndex;
    var result = _createHoldingPeriodBalance(gridYear, startIndex);
    for (int i = startIndex + 1; i < endIndex; i++) {
      result += _createHoldingPeriodBalance(gridYear, i);
    }
    return result;
  }

  HoldingPeriodBalance createTotalHoldingPeriodBalance(GridYear gridYear) {
    final startIndex = 0;
    final endIndex = numHoldings;
    var result = _createHoldingPeriodBalance(gridYear, startIndex);
    for (int i = startIndex + 1; i < endIndex; i++) {
      result += _createHoldingPeriodBalance(gridYear, i);
    }
    return result;
  }


  toString() => '''
holdings: $numHoldings
assets: $numAssets
liabilities: $numLiabilities
----------------------------------
${_printGrid()}
++++++++++++++++++++++++++++++++++
''';

  String _printGrid() {
    List<String> parts = [];

    String pv(int year, double value) =>
        '${shortYear(year)}=${moneyFormat(value)}';

    String gridHolding(GridHolding gh, int year) {
      return '${shortYear(year)}=$gh';
    }

    for (int i = 0; i < numAssets; i++) {
      parts.add(
          'A(${_assetInfos[i].name}) => ${_gridYears.map((gy) => pv(gy.year, gy.assetBalances[i].balance)).join(", ")}');
    }
    for (int i = 0; i < numLiabilities; i++) {
      parts.add(
          'L(${_liabilityInfos[i].name}) => ${_gridYears.map((gy) => pv(gy.year, gy.liabilityBalances[i].balance)).join(", ")}');
    }
    for (int i = 0; i < numHoldings; i++) {
      parts.add(
          'H(${_holdingInfos[i].holdingKey}) =>\n\t${_gridYears.map((gy) => gridHolding(gy.gridHoldings[i], gy.year)).join(",\n\t")}');
    }
    return parts.join('\n');
  }

  void _initializeReserveRates() {
    final reserveAssumptions = _assumptionModel.reserveAssumptions;
    _reserveShortfallRate = reserveAssumptions.shortfall;
    _reserveExcessRate = reserveAssumptions.excess;
  }

  void _initializeLinkPreferences() {
    _incomePreferredLinks = valueApply(
        _dossier.incomePreferredLinks,
        (List<HoldingKey> holdingKeys) => _matchingGridHoldings(holdingKeys).toList());
    _expensePreferredLinks = valueApply(
        _dossier.expensePreferredLinks,
        (List<HoldingKey> holdingKeys) => _matchingGridHoldings(holdingKeys).toList());
    _preferredExpenseSources = valueApply(
        _dossier.preferredExpenseSources,
        (List<HoldingKey> holdingKeys) => _matchingGridHoldings(holdingKeys).toList());
    _incomeHoldings =
        _matchingGridHoldings(_dossier.incomeHoldingKeys).toList(growable: false);
    _expenseHoldings =
        _matchingGridHoldings(_dossier.expenseHoldingKeys).toList(growable: false);

    plusLogFiner(_logger, () => '''\n
INCOME_PREFERRED:
-----
${_dossier.incomePreferredLinks.values.join("\n\t")}
-----
${
    _incomePreferredLinks.values.expand((lv) => lv)
      .map((i) => _holdingInfos[i])
      .join("\n\t")
}

EPENSE_PREFERRED:
${
    _expensePreferredLinks.values.expand((lv) => lv)
      .map((i) => _holdingInfos[i])
      .join("\n\t")
}

REMAINING_INCOME:
${_incomeHoldings.map((i) => _holdingInfos[i]).join("\n\t")}
REMAINING_EXPENSE:
${_expenseHoldings.map((i) => _holdingInfos[i]).join("\n\t")}
''');

  }

  int _matchingGridHolding(HoldingKey holdingKey) {
    for (int i = 0; i < numHoldings; i++) {
      if (_holdingInfos[i].holdingKey == holdingKey) {
        return i;
      }
    }
    assert(false);
    return null;
  }

  Iterable<int> _matchingGridHoldings(Iterable<HoldingKey> holdingKeys) =>
      holdingKeys.map((HoldingKey holdingKey) => _matchingGridHolding(holdingKey));


  void _initializeAssumptions(AssumptionModel assumptionModelOverride) {
    _assumptionModel = assumptionModelOverride == null ?
        _dossier.assumptionModel :
        assumptionModelOverride;
    _balanceSheetAssumptions = _assumptionModel.balanceSheetAssumptions;
    _flowModel = overrideFlowModel(_dossier.flowModel, _assumptionModel);
    _taxRateAssumptions = _assumptionModel.taxRateAssumptions;
  }

  void _initializeBalanceSheetItems() {
    _createHoldingInfos();
    _createAccountInfos();
    _createAssetInfos();
    _createLiabilityInfos();
  }

  void _initializeFlows() {
    _createIncomeInfos();
    _createExpenseInfos();
  }

  void _initializeGridYear(GridYear gridYear) {
    final gridHoldings = gridYear.gridHoldings;
    for (int i = 0; i < numHoldings; i++) {
      final holdingKey = _holdingInfos[i].holdingKey;
      final accountName = holdingKey.accountName;
      final reinvestmentPolicy =
          _balanceSheetAssumptions.getReinvestmentPolicy(holdingKey);

      gridHoldings[i] = new GridHolding(holdingKey, reinvestmentPolicy)
          ..distributionsSheltered =
              _dossier.distributionsSheltered(accountName)
          ..canCapitalGainBeSheltered =
              _dossier.canCapitalGainBeSheltered(accountName);
    }
    final assetBalances = gridYear.assetBalances;
    for (int i = 0; i < numAssets; i++) {
      assetBalances[i] = new GridBalance.empty();
    }
    final liabilityBalances = gridYear.liabilityBalances;
    for (int i = 0; i < numLiabilities; i++) {
      liabilityBalances[i] = new GridBalance.empty();
    }

  }

  void _initializeGrid() {
    final numYears = _completeYearRange.years;
    _gridYears = new List<GridYear>(numYears);
    Date prevEnd;
    for (int i = 0; i < numYears; i++) {
      final startYear = _completeYearRange.start + i;
      final startDate = prevEnd == null ? startOfYear(startYear) : prevEnd;
      final endDate = startOfYear(startYear + 1);
      final gridYear = _gridYears[i] = new GridYear(
          startDate,
          endDate,
          _holdingInfos.length,
          _assetInfos.length,
          _liabilityInfos.length);
      _initializeGridYear(gridYear);

      if (_trackDetails) {
        gridYear.forecastDetails = new ForecastDetails();
      }

      prevEnd = endDate;
    }
  }

  IncomeInfo _createIncomeInfo(String incomeName) {
    final incomeSpec = _flowModel.incomeModel[incomeName];
    final incomeFlowDetails = new List<FlowDetail>();
    incomeSpec.visitFlows(_completeDateRange, (Date date, double flow) {
      //print(' --- $incomeName $date $flow');
      final gridYear = this.gridYear(date.year);
      final flowDetail =
          new FlowDetail(date, incomeSpec.incomeType.value, flow, incomeName);
      gridYear.flowDetails.add(flowDetail);
      incomeFlowDetails.add(flowDetail);
    });
    final result = new IncomeInfo(incomeName, incomeSpec, incomeFlowDetails);
    return result;
  }

  void _createIncomeInfos() {
    _incomeInfos = _flowModel.incomeModel.keys.map(
        (String incomeName) => _createIncomeInfo(incomeName)).toList(growable: false);
  }

  ExpenseInfo _createExpenseInfo(String expenseName) {
    final expenseSpec = _flowModel.expenseModel[expenseName];
    final expenseFlowDetails = new List<FlowDetail>();
    expenseSpec.visitFlows(_completeDateRange, (Date date, double flow) {
      final gridYear = this.gridYear(date.year);
      final flowDetail =
          new FlowDetail(date, expenseSpec.expenseType.value, -flow, expenseName);
      gridYear.flowDetails.add(flowDetail);
      expenseFlowDetails.add(flowDetail);
    });
    final result =
        new ExpenseInfo(expenseName, expenseSpec, expenseFlowDetails);
    return result;
  }

  void _createExpenseInfos() {
    _expenseInfos = _flowModel.expenseModel.keys.map(
        (String expenseName) =>
            _createExpenseInfo(expenseName)).toList(growable: false);
  }

  void _createAccountInfos() {
    int startIndex = 0;
    int endIndex = 0;
    _accountInfos = new List<AccountInfo>();
    if (_holdingInfos.length > 0) {
      String currentAccount = _holdingInfos.first.holdingKey.accountName;

      void createAccount() {
        final portfolioAccount = _dossier.portfolioAccount(currentAccount);
        assert(portfolioAccount != null);
        _accountInfos.add(
            new AccountInfo(currentAccount, portfolioAccount, startIndex, endIndex));
        startIndex = endIndex;
      }

      for (HoldingInfo holdingInfo in _holdingInfos) {
        final accountName = holdingInfo.holdingKey.accountName;
        if (currentAccount != accountName) {
          createAccount();
        }
        currentAccount = accountName;
        endIndex++;
      }
      createAccount();
      assert(endIndex == _holdingInfos.length);
    }
  }

  HoldingInfo _createHoldingInfo(HoldingKey holdingKey, Holding holding) {
    final targetPartitions = _assumptionModel.targetPartitions;

    final instrumentPartitions =
        _balanceSheetAssumptions.getInstrumentPartitions(holdingKey);

    final distanceToTarget =
        targetPartitions.blendedDistance(instrumentPartitions);

    final curvesAttribution = new CurvesAttribution(
        _balanceSheetAssumptions.getHoldingReturns(holdingKey).returns);

    final reinvestmentPolicy =
        _balanceSheetAssumptions.getReinvestmentPolicy(holdingKey);

    return new HoldingInfo(
        holdingKey,
        holding,
        curvesAttribution,
        reinvestmentPolicy,
        instrumentPartitions,
        distanceToTarget);
  }

  void _createHoldingInfos() {
    final holdingCount = _dossier.holdingKeys.length;
    _holdingInfos = new List<HoldingInfo>(holdingCount);
    _holdingDistances = new List<HoldingDistance>(holdingCount);
    int i = 0;
    for (final holdingKey in _dossier.holdingKeys) {
      _holdingInfos[i] =
          _createHoldingInfo(holdingKey, _dossier.holding(holdingKey));
      _holdingDistances[i] = new HoldingDistance()..index = i;
      i++;
    }
  }

  void _forecastGrid() {
    _flowsProcessed = 0;
    final numYears = _gridYears.length;
    _forecastFirstGridYear();
    for (int i = 1; i < numYears; i++) {
      _forecastNextGridYear(i);
    }

    // assert(_flowsProcessed == _flowDetails.length +
    //     _gridYears.fold(0,
    //         (prev, elm) => prev + elm.standardFlowDetails.length));

    plusLogFine(_logger, () => toString());
  }

  void _growAssetsToFirstYear() {
    final assetBalances = _currentGridYear.assetBalances;
    for (int i = 0; i < numAssets; ++i) {
      final assetInfo = _assetInfos[i];
      final initialValue = assetInfo.asset.marketValue(_periodEnd);
      final growth = assetInfo.growth;
      assetBalances[i].balance =
          initialValue.value * growth.scaleFromTo(initialValue.date, _periodEnd);
    }
  }

  void _growLiabilitieisToFirstYear() {
    final liabilityBalances = _currentGridYear.liabilityBalances;
    for (int i = 0; i < numLiabilities; ++i) {
      final liabilityInfo = _liabilityInfos[i];
      final initialValue = liabilityInfo.liability.marketValue(_periodEnd);
      final growth = liabilityInfo.growth;
      liabilityBalances[i].balance =
          initialValue.value * growth.scaleFromTo(initialValue.date, _periodEnd);
    }
  }

  void _growHoldingsToFirstYear() {
    final holdings = _currentGridYear.gridHoldings;
    for (int i = 0; i < numHoldings; ++i) {
      final holdingInfo = _holdingInfos[i];
      final holding = holdingInfo.holding;
      final initialQuantity = holding.quantity.value;
      final initialCostBasis = holding.costBasis;
      final initialValue = holding.marketValue;
      final scaleDateRange = new DateRange(initialValue.date, _periodEnd);
      final curvesAttribution = holdingInfo.curvesAttribution;
      final attribution = curvesAttribution.scaleOnIntervals(scaleDateRange);
      final initialTotalValue = attribution.totalValue(initialValue.value);
      final isCash = holding.holdingType == HoldingType.CASH;

      final avgCostAccumulator = isCash ?
          new AvgCostAccumulator(
              initialTotalValue,
              initialTotalValue,
              initialTotalValue) :
          new AvgCostAccumulator(initialCostBasis, initialTotalValue, initialQuantity);

      holdings[i]
          ..growthAttribution = attribution
          ..avgCostAccumulator = avgCostAccumulator;
    }
  }

  _setGridYear(int yearIndex) {
    _currentGridYear = _gridYears[yearIndex];
    _periodEnd = _currentGridYear.endDate;
    if (yearIndex > 0) {
      _prevGridYear = _gridYears[yearIndex - 1];
      _prevPeriodEnd = _prevGridYear.endDate;
      _periodDateRange = new DateRange(_prevPeriodEnd, _periodEnd);
      assert(_prevGridYear.year + 1 == _currentGridYear.year);
    }
  }

  void _forecastFirstGridYear() {
    _setGridYear(0);
    _growAssetsToFirstYear();
    _growLiabilitieisToFirstYear();
    _growHoldingsToFirstYear();
  }

  void _updateBalance(GridBalance prevBalance, GridBalance current,
      RateCurve growth) {
    current.prevBalance = prevBalance.balance;
    current.balance =
        current.prevBalance * growth.scaleFromTo(_prevPeriodEnd, _periodEnd);
  }

  void _growAssetsFromPrevious(List<GridBalance> prevBalances,
      List<GridBalance> balances) {
    for (int i = 0; i < numAssets; ++i) {
      _updateBalance(prevBalances[i], balances[i], _assetInfos[i].growth);
    }
  }

  void _growLiabilitiesFromPrevious(List<GridBalance> prevBalances,
      List<GridBalance> balances) {
    for (int i = 0; i < numLiabilities; ++i) {
      _updateBalance(prevBalances[i], balances[i], _liabilityInfos[i].growth);
    }
  }

  void _pullDistributionsFromAttribution(Attribution attribution,
      double startValue, GridHolding holding) {
    var qd = attribution.contributionDelta(
        HoldingReturnType.QUALIFIED_DIVIDEND,
        startValue);
    var uqd = attribution.contributionDelta(
        HoldingReturnType.UNQUALIFIED_DIVIDEND,
        startValue);
    var cgd = attribution.contributionDelta(
        HoldingReturnType.CAPITAL_GAIN_DISTRIBUTION,
        startValue);
    var interest =
        attribution.contributionDelta(HoldingReturnType.INTEREST, startValue);

    assert(qd >= 0 && uqd >= 0 && cgd >= 0 && interest >= 0);

    final reinvestmentPolicy = holding.reinvestmentPolicy;
    final reinvestedDistributions = holding.reinvestedDistributions;
    final distributedDistributions = holding.distributedDistributions;
    final shelteredDistributions = holding.shelteredDistributions;
    final distributionsSheltered = holding.distributionsSheltered;

    if (reinvestmentPolicy.dividendsReinvested) {
      reinvestedDistributions
          ..qualified += qd
          ..unqualified += uqd
          ..capitalGainDistribution += cgd;
    } else {
      distributedDistributions
          ..qualified += qd
          ..unqualified += uqd
          ..capitalGainDistribution += cgd;
    }

    if (reinvestmentPolicy.interestReinvested) {
      reinvestedDistributions.interest += interest;
    } else {
      distributedDistributions.interest += interest;
    }

    if (distributionsSheltered) {
      shelteredDistributions
          ..qualified += qd
          ..unqualified += uqd
          ..capitalGainDistribution += cgd;






          //if(qd > 0 || uqd > 0 || cgd > 0) print("Found sheltered dist $shelteredDistributions");

    } else {
      _currentGridYear.taxableIncomeBreakdown
          ..qualifiedDividends += qd
          ..unqualifiedDividends += uqd
          ..capitalGainDistributions += cgd
          ..interest += interest;
    }
  }

  void _growHoldingsFromPrevious(List<GridHolding> prevHoldings,
      List<GridHolding> holdings) {
    for (int i = 0; i < numHoldings; ++i) {
      final holdingInfo = _holdingInfos[i];
      final currentHolding = holdings[i];
      final prevHolding = prevHoldings[i];
      final curvesAttribution = holdingInfo.curvesAttribution;
      final previousBalance = prevHolding.balance;

      final attribution = curvesAttribution.scaleOnIntervals(_periodDateRange);

      assert(attribution.attribution.values.every((v) => v.isFinite));
      assert(prevHolding.avgCostAccumulator != null);

      _pullDistributionsFromAttribution(
          attribution,
          previousBalance,
          currentHolding);

      final fullBalance = attribution.totalValue(previousBalance);
      final growthAttribution = attribution;
      final distributedDistributions = currentHolding.distributedDistributions;
      final totalDistributedDistributions = distributedDistributions.total;
      final reinvestedDistributions = currentHolding.reinvestedDistributions;
      final totalReinvestedDistributions = reinvestedDistributions.total;
      final avgCostAccumulator = prevHolding.avgCostAccumulator.copy();

      avgCostAccumulator.markValue(fullBalance);
      if (totalDistributedDistributions != 0.0) {
        avgCostAccumulator.deductDistribution(totalDistributedDistributions);
      }
      if (totalReinvestedDistributions != 0.0) {
        avgCostAccumulator.reinvestFunds(totalReinvestedDistributions);
      }

      _currentGridYear.distributionSummary
          ..distributed.plusEqual(distributedDistributions)
          ..reinvested.plusEqual(reinvestedDistributions);

      assert(currentHolding.fullBalance == 0.0);
      assert(attribution.attribution != null);

      currentHolding
          ..prevBalance = previousBalance
          ..fullBalance = fullBalance
          ..growthAttribution = growthAttribution
          ..avgCostAccumulator = avgCostAccumulator;
    }
  }

  void _growReservesFromPrevious() {
    final reserves = _currentGridYear.reserves;
    final prevReserves = _prevGridYear.reserves;

    final prevReservesBalance = prevReserves.balance;
    reserves.prevBalance = prevReservesBalance;
    reserves.balance = prevReservesBalance *
        (prevReservesBalance < 0 ?
            _reserveShortfallRate :
            _reserveExcessRate).scaleFromTo(_periodDateRange.start, _periodDateRange.end);
  }

  void _sortHoldingDistances() {
    final targetPartitions = _assumptionModel.targetPartitions;
    final holdingCount = numHoldings;
    for (int i = 0; i < holdingCount; i++) {
      final holdingInfo = _holdingInfos[i];
      final holdingDistance = _holdingDistances[i];
      final prevBalance = _prevGridYear.gridHoldings[i].balance;
      holdingDistance.distance = holdingInfo.distanceToTarget * prevBalance;
    }
    _holdingDistances.sort();

    plusLogFine(_logger, () => '''Holding Sort Order\n\t${
_holdingDistances
  .map((hd) => "${_holdingInfos[hd.index]} => $hd")
  .join("\n\t")
}
''');
  }

  void _forecastNextGridYear(int gridYearIndex) {
    _setGridYear(gridYearIndex);
    _processTaxBill();
    _sortHoldingDistances();
    _growAssetsFromPrevious(
        _prevGridYear.assetBalances,
        _currentGridYear.assetBalances);
    _growLiabilitiesFromPrevious(
        _prevGridYear.liabilityBalances,
        _currentGridYear.liabilityBalances);
    _growHoldingsFromPrevious(
        _prevGridYear.gridHoldings,
        _currentGridYear.gridHoldings);
    _growReservesFromPrevious();
    _processFlows();
    _processBuysAndSells();
  }

  void _processTaxBill() {
    _currentGridYear.taxBill =
        _prevGridYear.taxableIncomeBreakdown.generateTaxBill(
            _taxRateAssumptions,
            _currentGridYear.startDate);
  }

  void _processBuysAndSells() {
    double netTraded = 0.0;
    double totalBought = 0.0;
    double totalSold = 0.0;
    double taxableGain = 0.0;
    int i = 0;
    for (final holding in _currentGridYear.gridHoldings) {
      final netTrade = holding.netTrade;
      if (netTrade != 0) {





            //print('${_currentGridYear.year} trades occured on ${_holdingInfos[i]} for ${holding.netTrade}\n***\n${holding.avgCostAccumulator}');
        if (netTrade < 0) {
          totalSold -= netTrade;
          final gain = holding.avgCostAccumulator.sell(-netTrade);

          if (holding.canCapitalGainBeSheltered) {
            holding.shelteredCapitalGain += gain;
          } else {
            taxableGain += gain;
            holding.unshelteredCapitalGain += gain;
          }
        } else {
          totalBought += netTrade;
          holding.avgCostAccumulator.buy(netTrade);
        }





            //        print('${_currentGridYear.year} posttrade\n***\n${holding.avgCostAccumulator}');
        netTraded += netTrade;
      }
      i++;
    }
    _currentGridYear.taxableIncomeBreakdown.capitalGain = taxableGain;





        //print('${_currentGridYear.year} Bought $totalBought Sold $totalSold Net Traded $netTraded Net Gain $taxableGain');
  }

  double _adjustBalances(List<int> sources, FlowDetail flowDetail,
      double flow) {
    if (sources != null) {
      for (final gridHoldingIndex in sources) {
        final gridHolding = _currentGridYear.gridHoldings[gridHoldingIndex];
        final newFlow = gridHolding.adjustBalance(flow);
        if (_trackDetails) {
          if (newFlow != flow) {
            _currentGridYear.forecastDetails.registerAccountChange(
                flowDetail,
                flow - newFlow,
                gridHolding.holdingKey);
          }
        }
        flow = newFlow;
        if (flow == 0.0) break;
      }
    }
    return flow;
  }

  void _processTargetedIncomeFlow(FlowDetail flowDetail) {
    _flowsProcessed++;
    double flow = flowDetail.flow;

    _pullTaxableIncomes(flowDetail, _currentGridYear.taxableIncomeBreakdown);

    flow = _adjustBalances(
        _incomePreferredLinks[flowDetail.flowKey.name],
        flowDetail,
        flow);
    if (flow == 0.0) return;

    _currentGridYear.untargetedNetFlow += flow;

    if (_trackDetails) {
      _currentGridYear.forecastDetails.registerAccountChange(
          flowDetail,
          flow,
          ReserveHolding);
    }

  }

  void _processTargetedExpenseFlow(FlowDetail flowDetail) {
    _flowsProcessed++;

    double flow = flowDetail.flow;
    flow = _adjustBalances(
        _expensePreferredLinks[flowDetail.flowKey.name],
        flowDetail,
        flow);
    if (flow == 0.0) return;
    flow = _adjustBalances(
        _preferredExpenseSources[flowDetail.flowType],
        flowDetail,
        flow);
    if (flow == 0.0) return;

    _currentGridYear.untargetedNetFlow += flow;

    if (_trackDetails) {
      _currentGridYear.forecastDetails.registerAccountChange(
          flowDetail,
          flow,
          ReserveHolding);
    }

  }

  Iterable<FlowDetail> get _yearFlows =>
      concat(
          [
              _currentGridYear.flowDetails,
              _currentGridYear.standardIncomeFlowDetails,
              _currentGridYear.standardExpenseFlowDetails,]);

  void _processFlows() {
    _yearFlows.forEach(
        (FlowDetail flowDetail) =>
            flowDetail.flow < 0.0 ?
                _processTargetedExpenseFlow(flowDetail) :
                _processTargetedIncomeFlow(flowDetail));

    // Flows have been processed into targeted funds or untargetedNetFlow.
    double flow = _currentGridYear.untargetedNetFlow;

    if (flow < 0.0) {
      flow = _adjustBalances(_expenseHoldings, null, flow);
    } else if (flow > 0.0) {
      flow = _adjustBalances(_incomeHoldings, null, flow);
    }

    if (flow != 0.0) {
      assert(flow < 0.0);
      _currentGridYear.reserves.balance += flow;
      plusLogFine(
          _logger,
          () => '${_currentGridYear.year} Need to adjust reserves with $flow');
    }
  }

  void _createAssetInfos() {
    _assetInfos = new List(_dossier.assetKeys.length);
    int i = 0;
    _dossier.visitAssets(
        (String assetName, Asset asset) =>
            _assetInfos[i++] = new AssetInfo(
                assetName,
                asset,
                _balanceSheetAssumptions.assetAssumption(assetName)));
  }

  void _createLiabilityInfos() {
    _liabilityInfos = new List(_dossier.liabilityKeys.length);
    int i = 0;
    _dossier.visitLiabilities(
        (String liabilityName, Liability liability) =>
            _liabilityInfos[i++] = new LiabilityInfo(
                liabilityName,
                liability,
                _balanceSheetAssumptions.liabilityAssumption(liabilityName)));
  }

  // end <class ForecastGrid>
  final Dossier _dossier;
  bool _trackDetails = false;

      /// Range of forecast - *Note* range is user requested range plus additional year
  /// prior to requested start in order to bring assets, liabilities, holdings
  /// up to date for the specified start.
  YearRange _completeYearRange;
  DateRange _completeDateRange;
  AssumptionModel _assumptionModel;
  BalanceSheetAssumptions _balanceSheetAssumptions;
  Map<FlowKey, List<int>> _incomePreferredLinks;
  Map<FlowKey, List<int>> _expensePreferredLinks;
  Map<ExpenseType, List<int>> _preferredExpenseSources;
  List<int> _incomeHoldings;
  List<int> _expenseHoldings;
  List<HoldingDistance> _holdingDistances;
  DateRange _dateRange;
  List<GridYear> _gridYears;
  List<AccountInfo> _accountInfos;
  List<HoldingInfo> _holdingInfos;
  List<AssetInfo> _assetInfos;
  List<LiabilityInfo> _liabilityInfos;
  RateCurve _reserveShortfallRate;
  RateCurve _reserveExcessRate;
  FlowModel _flowModel;
  List<IncomeInfo> _incomeInfos;
  List<ExpenseInfo> _expenseInfos;
  GridYear _currentGridYear;
  GridYear _prevGridYear;
  Date _periodEnd;
  Date _prevPeriodEnd;
  DateRange _periodDateRange;
  int _flowsProcessed = 0;
  TaxRateAssumptions _taxRateAssumptions;
}

class HoldingDistance implements Comparable<HoldingDistance> {
  int compareTo(HoldingDistance other) {
    int result = 0;
    ((result = distance.compareTo(other.distance)) == 0) &&
        ((result = index.compareTo(other.index)) == 0);
    return result;
  }

  double distance;
  int index;
  // custom <class HoldingDistance>

  toString() => 'HD($distance, $index)';

  // end <class HoldingDistance>
}

/// Set of taxable items tracked - values depend on context
class TaxBreakdown {
  TaxBreakdown(this.pension, this.socialSecurity, this.rental, this.labor,
      this.capitalGain, this.qualifiedDividends, this.unqualifiedDividends,
      this.capitalGainDistributions, this.interest);

  double pension = 0.0;
  double socialSecurity = 0.0;
  double rental = 0.0;
  double labor = 0.0;
  double capitalGain = 0.0;
  double qualifiedDividends = 0.0;
  double unqualifiedDividends = 0.0;
  double capitalGainDistributions = 0.0;
  double interest = 0.0;
  // custom <class TaxBreakdown>

  TaxBreakdown.empty();

  double get total =>
      pension +
          socialSecurity +
          rental +
          labor +
          capitalGain +
          qualifiedDividends +
          unqualifiedDividends +
          capitalGainDistributions +
          interest;

  TaxBreakdown operator +(TaxBreakdown other) =>
      new TaxBreakdown(
          pension + other.pension,
          socialSecurity + other.socialSecurity,
          rental + other.rental,
          labor + other.labor,
          capitalGain + other.capitalGain,
          qualifiedDividends + other.qualifiedDividends,
          unqualifiedDividends + other.unqualifiedDividends,
          capitalGainDistributions + other.capitalGainDistributions,
          interest + other.interest);

  TaxBreakdown operator -(TaxBreakdown other) =>
      new TaxBreakdown(
          pension - other.pension,
          socialSecurity - other.socialSecurity,
          rental - other.rental,
          labor - other.labor,
          capitalGain - other.capitalGain,
          qualifiedDividends - other.qualifiedDividends,
          unqualifiedDividends - other.unqualifiedDividends,
          capitalGainDistributions - other.capitalGainDistributions,
          interest - other.interest);

  TaxBreakdown operator -() =>
      new TaxBreakdown(
          -pension,
          -socialSecurity,
          -rental,
          -labor,
          -capitalGain,
          -qualifiedDividends,
          -unqualifiedDividends,
          -capitalGainDistributions,
          -interest);

  void plusEqual(TaxBreakdown other) {
    pension += other.pension;
    socialSecurity += other.socialSecurity;
    rental += other.rental;
    labor += other.rental;
    capitalGain += other.capitalGain;
    qualifiedDividends += other.qualifiedDividends;
    unqualifiedDividends += other.unqualifiedDividends;
    capitalGainDistributions += other.capitalGainDistributions;
    interest -= other.interest;
  }

  // Assumes the values stored are taxable incomes
  TaxBreakdown generateTaxBill(TaxRateAssumptions taxRateAssumptions,
      Date startOfPeriod) {

    double taxComponent(double basis, RateCurve taxRate) =>
        (basis != 0.0) ? basis * taxRate.getRate(startOfPeriod) : 0.0;

    return new TaxBreakdown(
        taxComponent(pension, taxRateAssumptions.pensionIncome),
        taxComponent(socialSecurity, taxRateAssumptions.socialSecurityIncome),
        taxComponent(rental, taxRateAssumptions.rentalIncome),
        taxComponent(labor, taxRateAssumptions.ordinaryIncome),
        taxComponent(capitalGain, taxRateAssumptions.capitalGains),
        taxComponent(qualifiedDividends, taxRateAssumptions.dividends),
        taxComponent(unqualifiedDividends, taxRateAssumptions.ordinaryIncome),
        taxComponent(capitalGainDistributions, taxRateAssumptions.ordinaryIncome),
        taxComponent(interest, taxRateAssumptions.ordinaryIncome));
  }


  // end <class TaxBreakdown>
}

class GridYear {
  int year;
  Date startDate;
  Date endDate;
  List<GridHolding> gridHoldings;
  List<GridBalance> assetBalances;
  List<GridBalance> liabilityBalances;
  List<FlowDetail> flowDetails = [];
  ForecastDetails forecastDetails;
  DistributionSummary distributionSummary = new DistributionSummary.empty();
  double untargetedNetFlow = 0.0;
  GridBalance reserves;
  TaxBreakdown taxableIncomeBreakdown = new TaxBreakdown.empty();
  TaxBreakdown taxBill;
  // custom <class GridYear>

  GridYear(this.startDate, this.endDate, int numHoldings, int numAssets,
      int numLiabilities)
      : gridHoldings = new List<GridHolding>(numHoldings),
        assetBalances = new List<GridBalance>(numAssets),
        liabilityBalances = new List<GridBalance>(numLiabilities),
        reserves = new GridBalance.empty() {
    year = startDate.year;
  }

  GridBalance get totalHoldings {
    double prevBalance = 0.0,
        balance = 0.0;
    for (GridHolding gridHolding in gridHoldings) {
      prevBalance += gridHolding.prevBalance;
      balance += gridHolding.balance;
    }
    return new GridBalance(prevBalance, balance);
  }

  DistributionBreakdown get shelteredDistributions =>
      gridHoldings.fold(
          new DistributionBreakdown.empty(),
          (DistributionBreakdown prev, GridHolding holding) =>
              prev + holding.shelteredDistributions);


  double get shelteredCapitalGains =>
      gridHoldings.fold(
          0.0,
          (double prev, GridHolding holding) => prev + holding.shelteredCapitalGain);

  GridBalance get totalNonHoldingAssets => _sumHoldings(assetBalances);
  GridBalance get totalAssets =>
      totalHoldings..plusEqual(totalNonHoldingAssets);
  GridBalance get totalLiabilities => _sumHoldings(liabilityBalances);

  Iterable<FlowDetail> get standardExpenseFlowDetails {
    List result = [];
    result.add(
        new FlowDetail(
            endDate,
            ExpenseType.TAXES_FEDERAL.value,
            -taxBill.total,
            '^Tax Bill'));
    return result;
  }

  Iterable<FlowDetail> get standardIncomeFlowDetails {
    List result = [];

    {
      final qualified = distributionSummary.distributed.qualified;
      result.add(
          new FlowDetail(
              endDate,
              IncomeType.QUALIFIED_DIVIDEND_INCOME.value,
              qualified,
              '^Qualified Dividends'));
    }

    {
      final unqualified = distributionSummary.distributed.unqualified;
      result.add(
          new FlowDetail(
              endDate,
              IncomeType.NONQUALIFIED_DIVIDEND_INCOME.value,
              unqualified,
              '^Unqualified Dividends'));
    }

    {
      final capitalGainDistribution =
          distributionSummary.distributed.capitalGainDistribution;
      result.add(
          new FlowDetail(
              endDate,
              IncomeType.CAPITAL_GAIN_DISTRIBUTION_INCOME.value,
              capitalGainDistribution,
              '^Capital Gain Dist'));
    }

    {
      final interestDistribution = distributionSummary.distributed.interest;
      result.add(
          new FlowDetail(
              endDate,
              IncomeType.INTEREST_INCOME.value,
              interestDistribution,
              '^Interest'));
    }

    return result;
  }

  _sumHoldings(Iterable<GridBalance> balances) =>
      balances.fold(new GridBalance.empty(), (GridBalance result, GridBalance elm) {
    result.prevBalance += elm.prevBalance;
    result.balance += elm.balance;
    return result;
  });

  // end <class GridYear>
}

class FlowAccountLink {
  const FlowAccountLink(this.flowDetail, this.flowAllocation, this.holdingKey);

  final FlowDetail flowDetail;
  /// From the flow, the amount allocated to the holding
  final double flowAllocation;
  final HoldingKey holdingKey;
  // custom <class FlowAccountLink>
  // end <class FlowAccountLink>
}

class ForecastDetails {
  List<FlowAccountLink> flowAccountLinks = [];
  // custom <class ForecastDetails>

  void registerAccountChange(FlowDetail flowDetail, double flow,
      HoldingKey holdingKey) {
    assert(flowDetail == null ||
        (flowDetail.flow < 0.0 && flow <= 0.0) ||
        (flowDetail.flow > 0.0 && flow >= 0.0));

    flowAccountLinks.add(new FlowAccountLink(flowDetail, flow, holdingKey));
  }

  toString() {
  }

  // end <class ForecastDetails>
}

class GridHolding {
  HoldingKey holdingKey;
  ReinvestmentPolicy reinvestmentPolicy;
  bool distributionsSheltered = false;
  bool canCapitalGainBeSheltered = false;
  double prevBalance = 0.0;
  double fullBalance = 0.0;

      /// Details on modeled growth from start to end - (does *not* including sales/investments)
  Attribution growthAttribution;
  double netTrade = 0.0;
  DistributionBreakdown distributedDistributions =
      new DistributionBreakdown.empty();
  DistributionBreakdown reinvestedDistributions =
      new DistributionBreakdown.empty();
  DistributionBreakdown shelteredDistributions =
      new DistributionBreakdown.empty();
  AvgCostAccumulator avgCostAccumulator;
  double unshelteredCapitalGain = 0.0;
  double shelteredCapitalGain = 0.0;
  // custom <class GridHolding>

  GridHolding(this.holdingKey, this.reinvestmentPolicy);

  double get balance => avgCostAccumulator.totalValue;
  double get netFullBalance => fullBalance - distributedDistributions.total;

  Map<HoldingReturnType, num> get growthDetails =>
      valueApply(growthAttribution.attribution, (num factor) => prevBalance * factor);

  double _buyHolding(double amount) {
    netTrade += amount;
    return 0.0;
  }


  double get _netBalance => avgCostAccumulator.totalValue + netTrade;

  double _sellHolding(double amount) {
    double diff = _netBalance + amount;
    if (diff >= 0) {
      netTrade += amount;
      return 0.0;
    } else {
      netTrade = -balance;
      return diff;
    }
  }

  double adjustBalance(double amount) {
    assert(amount != 0.0);
    double remaining;
    if (amount > 0.0) {
      remaining = _buyHolding(amount);
    } else if (amount < 0.0) {
      remaining = _sellHolding(amount);
    }
    assert(_invariant);
    return remaining;
  }

  bool get _invariant => balance >= 0.0 && ((balance + netTrade) >= 0.0);

  toString() =>
      '$holdingKey (prev:${moneyFormat(prevBalance)},' 'bal:${moneyFormat(balance)},'
          'fullb:${moneyFormat(fullBalance)},' 'nettr:${moneyFormat(netTrade)},'
          'q:${moneyFormat(distributedDistributions.qualified)},'
          'u:${moneyFormat(distributedDistributions.unqualified)},'
          'c:${moneyFormat(distributedDistributions.capitalGainDistribution)},'
          'qr:${moneyFormat(reinvestedDistributions.qualified)},'
          'ur:${moneyFormat(reinvestedDistributions.unqualified)},'
          'cr:${moneyFormat(reinvestedDistributions.capitalGainDistribution)},'
          'distributed:${moneyFormat(distributedDistributions.total)}';

  // end <class GridHolding>
}

class GridBalance {
  double prevBalance = 0.0;
  double balance = 0.0;
  // custom <class GridBalance>

  GridBalance.empty();
  GridBalance(this.prevBalance, this.balance);

  void plusEqual(GridBalance other) {
    prevBalance += other.prevBalance;
    balance += other.balance;
  }

  // end <class GridBalance>
}
// custom <part grid>

void _pullTaxableIncomes(FlowDetail flowDetail,
    TaxBreakdown taxableIncomeBreakdown) {
  IncomeType incomeType = flowDetail.flowType;
  switch (incomeType) {
    case IncomeType.PENSION_INCOME:
      taxableIncomeBreakdown.pension += flowDetail.flow;
      break;
    case IncomeType.SOCIAL_SECURITY_INCOME:
      taxableIncomeBreakdown.socialSecurity += flowDetail.flow;
      break;
    case IncomeType.RENTAL_INCOME:
      taxableIncomeBreakdown.rental += flowDetail.flow;
      break;
    case IncomeType.LABOR_INCOME:
      taxableIncomeBreakdown.labor += flowDetail.flow;
      break;
    case IncomeType.CAPITAL_GAIN:
      taxableIncomeBreakdown.capitalGain += flowDetail.flow;
      break;
    default:
      break;
  }
  return;
}

typedef GridYearVisitor(GridYear gridYear);
typedef GridAssetVisitor(AssetInfo assetInfo, GridBalance gridBalance);
typedef GridLiabilityVisitor(LiabilityInfo liabilityInfo,
    GridBalance gridBalance);
typedef GridHoldingVisitor(HoldingInfo holdingInfo, GridHolding gridHolding);
typedef GridHoldingValueVisitor(HoldingInfo holdingInfo, double startValue,
    double endValue);
typedef GridFlowVisitor(String flowName, double amount);
typedef GridAccountVisitor(AccountInfo accountInfo);

// end <part grid>

