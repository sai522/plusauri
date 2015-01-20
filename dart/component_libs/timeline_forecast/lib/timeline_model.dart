library timeline_forecast.timeline_model;

import 'dart:collection';
import 'dart:math' show min, max;
import 'package:logging/logging.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/forecast.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/models/forecast.dart';
import 'package:plus/models/income_statement.dart';
import 'package:plus/models/liquidation_summary.dart';
import 'package:plus/time_series.dart';
import 'package:timeline_forecast/current_dollars.dart';
import 'package:timeline_forecast/timeline_enums.dart';
// custom <additional imports>

import 'package:plus/logging.dart';

// end <additional imports>

part 'src/timeline_model/grid_timeline.dart';

final _logger = new Logger('timeline_model');

abstract class ITimelineModel {
  // custom <class ITimelineModel>

  DateRange get dateRange;
  RateCurve get inflation;
  ForecastBalances get netWorth;
  ForecastBalances get reserves;
  ForecastBalances get netAssets;
  ForecastBalances get netLiabilities;
  ForecastFlows get netIncomes;
  ForecastFlows get netExpenses;
  ForecastFlows get netFlows;
  IAnnualForecastModel annualForecastModel(String label, int year);

  // end <class ITimelineModel>
}

/// Supports multiple models over specific multiyear period
class TimelineComparisonModel {
  /// Range of the forecasts - it is assumed all forecasts are on the same range
  DateRange get dateRange => _dateRange;
  Map<String, ITimelineModel> timelineModels = {};
  // custom <class TimelineComparisonModel>

  TimelineComparisonModel.fromDossierAssumptionsGrid(Dossier dossier,
      this._dateRange, Map<String, AssumptionModel> assumptionModels) {
    final yearRange = new YearRange(_dateRange.start.year, _dateRange.end.year);

    assumptionModels.forEach((String key, AssumptionModel assumptionModel) {
      final sw = new Stopwatch()..start();
      final grid = new ForecastGrid.fromDossier(dossier, yearRange,
          trackDetails: true, assumptionModelOverride: assumptionModel);
      final millis = sw.elapsedMilliseconds;
      sw.reset();
      timelineModels[key] =
          new GridTimelineModel(grid, assumptionModel.inflation);
      sw.stop();
      plusLogWarning(_logger, () => 'Forecast $key took ${millis} ms '
          'TimelineModel creation took ${sw.elapsedMilliseconds} ms');
    });
  }

  // end <class TimelineComparisonModel>
  DateRange _dateRange;
}

abstract class IBalanceSheetModel {
  // custom <class IBalanceSheetModel>

  int get year;
  Date get startDate;
  Date get endDate;
  void visitAssets(BSMBalanceVisitor visitor);
  void visitLiabilities(BSMBalanceVisitor visitor);
  void visitAccounts(BSMAccountHoldingVisitor visitor);
  void visitAccountOtherHoldings(
      String accountName, BSMHoldingValueVisitor visitor);

  /// Visits each symbol holding in account
  void visitAccountHoldings(String accountName, BSMHoldingValueVisitor visitor);

  /// Visits account, calls back with totals
  void visitAccountTotalHoldings(
      String accountName, BSMHoldingValueVisitor visitor);

  PeriodBalance get totalHoldings;
  PeriodBalance get totalNonHoldingAssets;
  PeriodBalance get totalAssets;
  PeriodBalance get reserves;
  PeriodBalance get totalLiabilities;

  HoldingPeriodBalance createHoldingPeriodBalance(
      String accountName, String holdingName);
  HoldingPeriodBalance createAccountHoldingPeriodBalance(String accountName);
  HoldingPeriodBalance createTotalHoldingPeriodBalance();

  // end <class IBalanceSheetModel>
}

abstract class IIncomeStatementModel {
  // custom <class IIncomeStatementModel>

  int get year;
  int get numIncomes;
  int get numExpenses;

  void visitIncomes(visitor(String incomeName, double amount));
  void visitExpenses(visitor(String expenseName, double amount));
  void visitObligatoryExpenses(visitor(String expenseName, double amount));
  void visitPVObligatoryExpenses(
      RateCurve rateCurve, visitor(String expenseName, double amount));

  // end <class IIncomeStatementModel>
}

abstract class ITaxSummaryModel {
  // custom <class ITaxSummaryModel>

  void visitPension(TaxSummaryVisitor visitor);
  void visitSocialSecurity(TaxSummaryVisitor visitor);
  void visitRental(TaxSummaryVisitor visitor);
  void visitLabor(TaxSummaryVisitor visitor);
  void visitCapitalGain(TaxSummaryVisitor visitor);
  void visitQualifiedDividends(TaxSummaryVisitor visitor);
  void visitUnqualifiedDividends(TaxSummaryVisitor visitor);
  void visitCapitalGainDistributions(TaxSummaryVisitor visitor);
  void visitInterest(TaxSummaryVisitor visitor);

  void visitShelteredCapitalGain(TaxSummaryVisitor visitor);
  void visitShelteredQualifiedDividends(TaxSummaryVisitor visitor);
  void visitShelteredUnqualifiedDividends(TaxSummaryVisitor visitor);
  void visitShelteredCapitalGainDistributions(TaxSummaryVisitor visitor);
  void visitShelteredInterest(TaxSummaryVisitor visitor);

  double get totalTaxes;

  // end <class ITaxSummaryModel>
}

abstract class ILiquidationSummaryModel {
  // custom <class ILiquidationSummaryModel>

  int get year;
  void visitCredits(CreditVisitor creditVisitor);
  void visitDebits(DebitVisitor debitVisitor);

  // end <class ILiquidationSummaryModel>
}

abstract class IAnnualForecastModel {
  // custom <class IAnnualForecastModel>

  String get title;
  int get year;
  IBalanceSheetModel get balanceSheetModel;
  IIncomeStatementModel get incomeStatementModel;
  ITaxSummaryModel get taxSummaryModel;
  ILiquidationSummaryModel get liquidationSummaryModel;
  CurrentDollarsToggler get currentDollarsToggler;

  void visitExtendedLiabilities(RateCurve discount, AFVisitor visitor);

  // end <class IAnnualForecastModel>
}

class ForecastBalances {
  ForecastBalances(this._title, this._periodBalances) {
    // custom <ForecastBalances>
    if (_periodBalances != null) findMinMax();
    // end <ForecastBalances>
  }

  String get title => _title;
  List<PeriodBalance> get periodBalances => _periodBalances;
  double get minBalance => _minBalance;
  double get maxBalance => _maxBalance;
  // custom <class ForecastBalances>

  get length => _periodBalances.length;

  findMinMax() => _periodBalances.forEach((pb) {
    _minBalance = min(_minBalance, pb.end.value);
    _maxBalance = max(_maxBalance, pb.end.value);
  });

  double scaleBalance(double balance, double minTarget, double maxTarget,
      [double minBalance, double maxBalance]) {
    if (minBalance == null) minBalance = _minBalance;
    if (maxBalance == null) maxBalance = _maxBalance;

    return (maxBalance == minBalance)
        ? (maxTarget - minTarget) / 2.0
        : minTarget +
            ((balance - minBalance) / (maxBalance - minBalance)) *
                (maxTarget - minTarget);
  }

  // end <class ForecastBalances>
  String _title;
  List<PeriodBalance> _periodBalances = [];
  double _minBalance = double.MAX_FINITE;
  double _maxBalance = 0.0;
}

/// Create a ForecastBalances sans new, for more declarative construction
ForecastBalances forecastBalances(
    [String _title, List<PeriodBalance> _periodBalances]) =>
        new ForecastBalances(_title, _periodBalances);

class YearIncomeFlows {
  int year = 0;
  double netFlow = 0.0;
  // custom <class YearIncomeFlows>

  // end <class YearIncomeFlows>
}

yearIncomeFlows() => new YearIncomeFlows();

class ForecastFlows {
  ForecastFlows(this._title, this._flowsByYear);

  String get title => _title;
  List<YearIncomeFlows> get flowsByYear => _flowsByYear;
  double get minFlow => _minFlow;
  double get maxFlow => _maxFlow;
  // custom <class ForecastFlows>

  findMinMax() => _flowsByYear.forEach((fby) {
    _minFlow = min(_minFlow, fby.netFlow);
    _maxFlow = max(_maxFlow, fby.netFlow);
  });

  // end <class ForecastFlows>
  String _title;
  List<YearIncomeFlows> _flowsByYear = [];
  double _minFlow = double.MAX_FINITE;
  double _maxFlow = 0.0;
}

/// Create a ForecastFlows sans new, for more declarative construction
ForecastFlows forecastFlows(
    [String _title, List<YearIncomeFlows> _flowsByYear]) =>
        new ForecastFlows(_title, _flowsByYear);

// custom <library timeline_model>

ForecastBalances balancesByType(
    ITimelineModel model, BalanceDisplayType displayType) {
  switch (displayType) {
    case NET_WORTH_BALANCE:
      return model.netWorth;
    case TOTAL_ASSETS_BALANCE:
      return model.netAssets;
    case TOTAL_LIABILITIES_BALANCE:
      return model.netLiabilities;
  }
}

ForecastFlows flowsByType(ITimelineModel model, FlowDisplayType displayType) {
  switch (displayType) {
    case NET_INCOME_FLOW:
      return model.netFlows;
    case TOTAL_INCOME_FLOW:
      return model.netIncomes;
    case TOTAL_EXPENSE_FLOW:
      return model.netExpenses;
  }
  assert(false);
}

typedef BSMBalanceVisitor(
    String balanceName, double startValue, double endValue);
typedef BSMHoldingVisitor(String holdingName, HoldingPeriodBalance hpb);
typedef BSMHoldingValueVisitor(
    HoldingKey holdingKey, double startValue, double endValue);
typedef BSMAccountHoldingVisitor(String accountName, int numHoldings);

// Annula Forecast Visitor
typedef AFVisitor(
    String itemName, double startValue, double endValue, bool isExtended);

typedef CreditVisitor(HoldingKey holdingKey, String incomeName,
    double creditAmount, double holdingBalance);

typedef DebitVisitor(HoldingKey holdingKey, String expenseName,
    double expenseAmount, double holdingBalance);

typedef TaxSummaryVisitor(double basis, double assessedTax);

// end <library timeline_model>
