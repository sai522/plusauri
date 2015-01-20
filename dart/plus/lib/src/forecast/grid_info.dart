part of plus.forecast;

class AccountInfo {
  const AccountInfo(
      this.accountName, this.portfolioAccount, this.startIndex, this.endIndex);

  final String accountName;
  final PortfolioAccount portfolioAccount;
  /// Start index into holding infos for this account
  final int startIndex;
  /// Start index into holding infos for this account
  final int endIndex;
  // custom <class AccountInfo>

  int get numSymbolHoldings => endIndex - startIndex - 1;

  // end <class AccountInfo>
}

class HoldingInfo {
  const HoldingInfo(this.holdingKey, this.holding, this.curvesAttribution,
      this.reinvestmentPolicy, this.instrumentPartitions,
      this.distanceToTarget);

  final HoldingKey holdingKey;
  final Holding holding;
  final CurvesAttribution curvesAttribution;
  final ReinvestmentPolicy reinvestmentPolicy;
  final InstrumentPartitions instrumentPartitions;
  final double distanceToTarget;
  // custom <class HoldingInfo>

  String get accountName => holdingKey.accountName;
  String get holdingName => holdingKey.holdingName;

  toString() => 'HI($holdingKey, $distanceToTarget)';
  // end <class HoldingInfo>
}

/// Wraps asset name and type
class AssetInfo {
  const AssetInfo(this.name, this.asset, this.growth);

  final String name;
  final Asset asset;
  final RateCurve growth;
  // custom <class AssetInfo>

  toString() => 'Asset($name)';

  // end <class AssetInfo>
}

/// Wraps liability name and type
class LiabilityInfo {
  const LiabilityInfo(this.name, this.liability, this.growth);

  final String name;
  final Liability liability;
  final RateCurve growth;
  // custom <class LiabilityInfo>

  toString() => 'Liability($name)';

  // end <class LiabilityInfo>
}

class IncomeInfo {
  IncomeInfo(this.name, this.incomeSpec, this.flowDetails);

  final String name;
  final IncomeSpec incomeSpec;
  final List<FlowDetail> flowDetails;
  // custom <class IncomeInfo>

  Iterable<FlowDetail> flowsOnYearIterator(int year) => flowDetails
      .skipWhile((FlowDetail flowDetail) => flowDetail.date.year < year)
      .takeWhile((FlowDetail flowDetail) => flowDetail.date.year == year);

  String toString() => '$name(${flowDetails.length} inc flows)';

  // end <class IncomeInfo>
}

class ExpenseInfo {
  ExpenseInfo(this.name, this.expenseSpec, this.flowDetails);

  final String name;
  final ExpenseSpec expenseSpec;
  final List<FlowDetail> flowDetails;
  // custom <class ExpenseInfo>

  Iterable<FlowDetail> flowsOnYearIterator(int year) => flowDetails
      .skipWhile((FlowDetail flowDetail) => flowDetail.date.year < year)
      .takeWhile((FlowDetail flowDetail) => flowDetail.date.year == year);

  double pvFromYear(int year, RateCurve discount) {
    final endDate = endOfYear(year);
    List<DateValue> flows = new List.from(flowDetails
        .skipWhile((FlowDetail flowDetail) => flowDetail.date.year < year)
        .map((FlowDetail flowDetail) =>
            new DateValue(flowDetail.date, flowDetail.flow)), growable: false);
    print("Calculating pv of $flows");
    final sequence = new CFlowSequence.assumeSorted(flows);
    return sequence.valueOn(endDate, discount);
  }

  String toString() => '$name(${flowDetails.length} exp flows)';

  ExpenseType get expenseType => expenseSpec.expenseType;

  // end <class ExpenseInfo>
}
// custom <part grid_info>

// end <part grid_info>
