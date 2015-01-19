library t_f_holding_period_balance;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/models/forecast.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/composite_table.dart';
import 'package:tooltip/components/tooltip.dart';
import 't_f_partitions.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFHoldingPeriodBalance");

@CustomTag("plus-t-f-holding-period-balance")
class TFHoldingPeriodBalance extends PolymerElement {
  @observable String year;
  @observable String account;
  @observable String symbol;

  TFHoldingPeriodBalance.created() : super.created() {
    _logger.fine('TFHoldingPeriodBalance created sr => $shadowRoot');
    // custom <TFHoldingPeriodBalance created>

    // end <TFHoldingPeriodBalance created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFHoldingPeriodBalance domReady with sr => $shadowRoot');
    // custom <TFHoldingPeriodBalance domReady>
    // end <TFHoldingPeriodBalance domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFHoldingPeriodBalance ready with sr => $shadowRoot');
    // custom <TFHoldingPeriodBalance ready>
    // end <TFHoldingPeriodBalance ready>

  }

  @override
  void attached() {
    // custom <TFHoldingPeriodBalance pre-attached>
    // end <TFHoldingPeriodBalance pre-attached>

    super.attached();
    _logger.fine('TFHoldingPeriodBalance attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFHoldingPeriodBalance attached>

    _holdingTable = $['holding-period-balance-table'];
    _compositeTable = new CompositeTable(_holdingTable);

    for(RowType rowType in RowType.values) {
      final rowTitle = _RowTitles[rowType];
      if(isIdentifierRow(rowType)) {
        _compositeTable.addTopRow(rowTitle)
          ..addColumns(2)
          ..cellContents(0, rowTitle)
          ..cells[1].attributes['colspan'] = '2';
      } else if(rowType == IDENTIFIER_DIVIDER_ROW ||
          rowType == COST_BASIS_DIVIDER_ROW ||
          rowType == END_BALANCE_DIVIDER_ROW) {
        _compositeTable.addTopRow(rowTitle)
          ..addColumns(2)
          ..cellContents(0, '<hr>')
          ..cells[0].attributes['colspan'] = '3';
      } else {
        final addedRow = _compositeTable.addTopRow(rowTitle)
          ..addColumns(3)
          ..cellContents(0, rowTitle);
        if(isIndentedRow(rowType))
          addedRow.cells[0].classes.add('indent');
        if(rowType == END_BALANCE_ROW) {

        }
      }
    }

    // end <TFHoldingPeriodBalance attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFHoldingPeriodBalance)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFHoldingPeriodBalance>

  setModel(String account, String symbol, HoldingPeriodBalance hpb) {
    _model = hpb;
    final endValuePartitions = hpb.endValuePartitions;
    final endDate = hpb.end.date;
    final startDate = hpb.start.date;
    final startBalance = hpb.startValue;
    final endBalance = hpb.end.value;
    final totalReturn = hpb.totalReturn;

    final capitalAppreciation = hpb.capitalAppreciation;
    final distributed = hpb.distributionSummary.distributed;
    final reinvested = hpb.distributionSummary.reinvested;

    final interestDistributions = hpb.interestDistributions;
    final capitalGainDistributions = hpb.capitalGainDistributions;
    final qualifiedDistributions = hpb.qualifiedDistributions;
    final unqualifiedDistributions = hpb.unqualifiedDistributions;

    final interestReinvested = hpb.interestReinvested;
    final capitalGainReinvested = hpb.capitalGainReinvested;
    final qualifiedReinvested = hpb.qualifiedReinvested;
    final unqualifiedReinvested = hpb.unqualifiedReinvested;

    final startCostBasis = hpb.costBasis.startValue;
    final endCostBasis = hpb.costBasis.endValue;
    final soldInvested = hpb.soldInvested;
    final distributions = hpb.distributions;
    final capitalGain = hpb.capitalGain;

    ($['partitions'] as TFPartitions)
    .onAttached((TFPartitions tfPartitions) =>
      tfPartitions.setPartitions(endValuePartitions.allocation,
          endValuePartitions.style,
          endValuePartitions.capitalization));

    setRowValue(ACCOUNT_ROW, account);
    setRowValue(SYMBOL_ROW, symbol);
    setRowValue(START_DATE_ROW, '${dateFormat(startDate.dateTime)}');
    setRowValue(START_BALANCE_ROW, '${moneyFormat(startBalance, false)}');
    setRowValue(END_DATE_ROW, '${dateFormat(endDate.dateTime)}');
    setRowValue(END_BALANCE_ROW, '${moneyFormat(endBalance, false)}');
    setRowValue(TOTAL_RETURN_ROW, '${moneyFormat(totalReturn, false)}');

    // Non-identifier rows
    setRowValue(INTEREST_ROW,'${moneyFormat(interestDistributions, false)}');
    setRowValue(CAPITAL_APPRECIATION_ROW,'${moneyFormat(capitalAppreciation, false)}');
    setRowValue(QUALIFIED_DIVIDENDS_ROW, '${moneyFormat(qualifiedDistributions, false)}');
    setRowValue(UNQUALIFIED_DIVIDENDS_ROW, '${moneyFormat(unqualifiedDistributions, false)}');
    setRowValue(CAPITAL_GAIN_DISTRIBUTIONS_ROW,
        '${moneyFormat(capitalGainDistributions, false)}');

    setRowValue(REINVESTED_INTEREST_ROW,'${moneyFormat(interestReinvested, false)}');
    setRowValue(REINVESTED_QUALIFIED_DIVIDENDS_ROW, '${moneyFormat(qualifiedReinvested, false)}');
    setRowValue(REINVESTED_UNQUALIFIED_DIVIDENDS_ROW, '${moneyFormat(unqualifiedReinvested, false)}');
    setRowValue(REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW,
        '${moneyFormat(capitalGainReinvested, false)}');

    setRowValue(TOTAL_DISTRIBUTIONS_ROW, '${moneyFormat(distributions, false)}');

    if(startBalance != 0) {
      growth(double value) => value == 0.0? '__' :
        percentFormat(ccToAnnual(ccRate(dateValue(startDate, startBalance),
                    dateValue(endDate, startBalance + value))));

      setRowPct(TOTAL_RETURN_ROW, '${growth(totalReturn)}', hideEmpty:false);
      setRowPct(INTEREST_ROW,'${growth(interestDistributions)}');
      setRowPct(CAPITAL_APPRECIATION_ROW, '${growth(capitalAppreciation)}');
      setRowPct(CAPITAL_GAIN_DISTRIBUTIONS_ROW, '${growth(capitalGainDistributions)}');
      setRowPct(QUALIFIED_DIVIDENDS_ROW, '${growth(qualifiedDistributions)}');
      setRowPct(UNQUALIFIED_DIVIDENDS_ROW, '${growth(unqualifiedDistributions)}');

      setRowPct(REINVESTED_INTEREST_ROW,'${growth(interestReinvested)}');
      setRowPct(REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW, '${growth(capitalGainReinvested)}');
      setRowPct(REINVESTED_QUALIFIED_DIVIDENDS_ROW, '${growth(qualifiedReinvested)}');
      setRowPct(REINVESTED_UNQUALIFIED_DIVIDENDS_ROW, '${growth(unqualifiedReinvested)}');
      setRowPct(TOTAL_DISTRIBUTIONS_ROW, '${growth(distributions)}');
    }

    setRowValue(START_COST_BASIS_ROW, '${moneyFormat(startCostBasis, false)}');
    setRowValue(END_COST_BASIS_ROW, '${moneyFormat(endCostBasis, false)}');
    setRowValue(REALIZED_GAIN_ROW, '${moneyFormat(capitalGain, false)}');
    setRowValue(SOLD_INVESTED_ROW, '${moneyFormat(soldInvested, false)}');
    setRowValue(UNREALIZED_GAIN_ROW, '${moneyFormat(endBalance-endCostBasis, false)}');
    if(endCostBasis != 0.0 || soldInvested != 0.0) {
      setRowPct(UNREALIZED_GAIN_ROW,
          '${percentFormat((endBalance - endCostBasis)/endCostBasis, true)}');
      showCostBasisSection();
    } else {
      hideCostBasisSection();
    }
  }

  static const _CostBasisSection = const [
    START_COST_BASIS_ROW, END_COST_BASIS_ROW,
    REALIZED_GAIN_ROW, SOLD_INVESTED_ROW, UNREALIZED_GAIN_ROW,
    COST_BASIS_DIVIDER_ROW
  ];

  hideCostBasisSection() =>
      _CostBasisSection
        .forEach((rowType) =>
            _compositeTable.getRow(_RowTitles[rowType]).hide());

  showCostBasisSection() =>
      _CostBasisSection
        .forEach((rowType) =>
            _compositeTable.getRow(_RowTitles[rowType]).show());


  setRowValue(RowType rowType, String value) =>
    _compositeTable.getRow(_RowTitles[rowType]).cellContents(1, value);

  setRowPct(RowType rowType, String value, {bool hideEmpty:true}) {
    final row = _compositeTable
      .getRow(_RowTitles[rowType])
      ..cellContents(2, value);

    (hideEmpty && value == '__') ? row.hide() : row.show();
  }

  bool isIdentifierRow(RowType rowType) =>
    rowType.value <= START_BALANCE_ROW.value ||
    rowType.value == END_BALANCE_ROW.value;

  bool isIndentedRow(RowType rowType) =>
    rowType.value < TOTAL_DISTRIBUTIONS_ROW.value &&
        rowType.value > TOTAL_RETURN_ROW.value;

  static const _RowTitles = const {
    ACCOUNT_ROW : 'Account',
    SYMBOL_ROW : 'Symbol',
    START_DATE_ROW : 'Start Date',
    END_DATE_ROW : 'End Date',
    START_BALANCE_ROW : 'Start Balance',
    TOTAL_RETURN_ROW : 'Period Return',
    IDENTIFIER_DIVIDER_ROW : 'Identifier Divider',
    CAPITAL_APPRECIATION_ROW : 'Capital Appreciation',
    INTEREST_ROW: '* Interest',
    QUALIFIED_DIVIDENDS_ROW: '* Qualified Dividends',
    UNQUALIFIED_DIVIDENDS_ROW: '* Unqualified Dividends',
    CAPITAL_GAIN_DISTRIBUTIONS_ROW: '* Capital Gain Distributions',
    REINVESTED_INTEREST_ROW: 'Interest',
    REINVESTED_QUALIFIED_DIVIDENDS_ROW: 'Qualified Dividends',
    REINVESTED_UNQUALIFIED_DIVIDENDS_ROW: 'Unqualified Dividends',
    REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW: 'Capital Gain Distributions',
    TOTAL_DISTRIBUTIONS_ROW: '* Non-Reinvested Distributions',
    COST_BASIS_DIVIDER_ROW : 'Cost Basis Divider',
    START_COST_BASIS_ROW: 'Start Cost Basis',
    END_COST_BASIS_ROW: 'End Cost Basis',
    REALIZED_GAIN_ROW: 'Realized Gain',
    SOLD_INVESTED_ROW: '(Sold)/Invested',
    UNREALIZED_GAIN_ROW: 'Remaining Unrealized Gain',
    END_BALANCE_DIVIDER_ROW: 'End Balance Divider',
    END_BALANCE_ROW : 'End Balance',
  };

  // end <class TFHoldingPeriodBalance>
  HoldingPeriodBalance _model;
  TableElement _holdingTable;
  CompositeTable _compositeTable;
  List<CompositeRow> _componentRows;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}

/// Types of rows in TFHoldingPeriodBalance
class RowType implements Comparable<RowType> {
  static const ACCOUNT_ROW = const RowType._(0);
  static const SYMBOL_ROW = const RowType._(1);
  static const START_DATE_ROW = const RowType._(2);
  static const END_DATE_ROW = const RowType._(3);
  static const START_BALANCE_ROW = const RowType._(4);
  static const IDENTIFIER_DIVIDER_ROW = const RowType._(5);
  static const TOTAL_RETURN_ROW = const RowType._(6);
  static const CAPITAL_APPRECIATION_ROW = const RowType._(7);
  static const INTEREST_ROW = const RowType._(8);
  static const QUALIFIED_DIVIDENDS_ROW = const RowType._(9);
  static const UNQUALIFIED_DIVIDENDS_ROW = const RowType._(10);
  static const CAPITAL_GAIN_DISTRIBUTIONS_ROW = const RowType._(11);
  static const REINVESTED_INTEREST_ROW = const RowType._(12);
  static const REINVESTED_QUALIFIED_DIVIDENDS_ROW = const RowType._(13);
  static const REINVESTED_UNQUALIFIED_DIVIDENDS_ROW = const RowType._(14);
  static const REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW = const RowType._(15);
  static const TOTAL_DISTRIBUTIONS_ROW = const RowType._(16);
  static const COST_BASIS_DIVIDER_ROW = const RowType._(17);
  static const SOLD_INVESTED_ROW = const RowType._(18);
  static const START_COST_BASIS_ROW = const RowType._(19);
  static const END_COST_BASIS_ROW = const RowType._(20);
  static const REALIZED_GAIN_ROW = const RowType._(21);
  static const UNREALIZED_GAIN_ROW = const RowType._(22);
  static const END_BALANCE_DIVIDER_ROW = const RowType._(23);
  static const END_BALANCE_ROW = const RowType._(24);

  static get values => [
    ACCOUNT_ROW,
    SYMBOL_ROW,
    START_DATE_ROW,
    END_DATE_ROW,
    START_BALANCE_ROW,
    IDENTIFIER_DIVIDER_ROW,
    TOTAL_RETURN_ROW,
    CAPITAL_APPRECIATION_ROW,
    INTEREST_ROW,
    QUALIFIED_DIVIDENDS_ROW,
    UNQUALIFIED_DIVIDENDS_ROW,
    CAPITAL_GAIN_DISTRIBUTIONS_ROW,
    REINVESTED_INTEREST_ROW,
    REINVESTED_QUALIFIED_DIVIDENDS_ROW,
    REINVESTED_UNQUALIFIED_DIVIDENDS_ROW,
    REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW,
    TOTAL_DISTRIBUTIONS_ROW,
    COST_BASIS_DIVIDER_ROW,
    SOLD_INVESTED_ROW,
    START_COST_BASIS_ROW,
    END_COST_BASIS_ROW,
    REALIZED_GAIN_ROW,
    UNREALIZED_GAIN_ROW,
    END_BALANCE_DIVIDER_ROW,
    END_BALANCE_ROW
  ];

  final int value;

  int get hashCode => value;

  const RowType._(this.value);

  copy() => this;

  int compareTo(RowType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case ACCOUNT_ROW: return "AccountRow";
      case SYMBOL_ROW: return "SymbolRow";
      case START_DATE_ROW: return "StartDateRow";
      case END_DATE_ROW: return "EndDateRow";
      case START_BALANCE_ROW: return "StartBalanceRow";
      case IDENTIFIER_DIVIDER_ROW: return "IdentifierDividerRow";
      case TOTAL_RETURN_ROW: return "TotalReturnRow";
      case CAPITAL_APPRECIATION_ROW: return "CapitalAppreciationRow";
      case INTEREST_ROW: return "InterestRow";
      case QUALIFIED_DIVIDENDS_ROW: return "QualifiedDividendsRow";
      case UNQUALIFIED_DIVIDENDS_ROW: return "UnqualifiedDividendsRow";
      case CAPITAL_GAIN_DISTRIBUTIONS_ROW: return "CapitalGainDistributionsRow";
      case REINVESTED_INTEREST_ROW: return "ReinvestedInterestRow";
      case REINVESTED_QUALIFIED_DIVIDENDS_ROW: return "ReinvestedQualifiedDividendsRow";
      case REINVESTED_UNQUALIFIED_DIVIDENDS_ROW: return "ReinvestedUnqualifiedDividendsRow";
      case REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW: return "ReinvestedCapitalGainDistributionsRow";
      case TOTAL_DISTRIBUTIONS_ROW: return "TotalDistributionsRow";
      case COST_BASIS_DIVIDER_ROW: return "CostBasisDividerRow";
      case SOLD_INVESTED_ROW: return "SoldInvestedRow";
      case START_COST_BASIS_ROW: return "StartCostBasisRow";
      case END_COST_BASIS_ROW: return "EndCostBasisRow";
      case REALIZED_GAIN_ROW: return "RealizedGainRow";
      case UNREALIZED_GAIN_ROW: return "UnrealizedGainRow";
      case END_BALANCE_DIVIDER_ROW: return "EndBalanceDividerRow";
      case END_BALANCE_ROW: return "EndBalanceRow";
    }
    return null;
  }

  static RowType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "AccountRow": return ACCOUNT_ROW;
      case "SymbolRow": return SYMBOL_ROW;
      case "StartDateRow": return START_DATE_ROW;
      case "EndDateRow": return END_DATE_ROW;
      case "StartBalanceRow": return START_BALANCE_ROW;
      case "IdentifierDividerRow": return IDENTIFIER_DIVIDER_ROW;
      case "TotalReturnRow": return TOTAL_RETURN_ROW;
      case "CapitalAppreciationRow": return CAPITAL_APPRECIATION_ROW;
      case "InterestRow": return INTEREST_ROW;
      case "QualifiedDividendsRow": return QUALIFIED_DIVIDENDS_ROW;
      case "UnqualifiedDividendsRow": return UNQUALIFIED_DIVIDENDS_ROW;
      case "CapitalGainDistributionsRow": return CAPITAL_GAIN_DISTRIBUTIONS_ROW;
      case "ReinvestedInterestRow": return REINVESTED_INTEREST_ROW;
      case "ReinvestedQualifiedDividendsRow": return REINVESTED_QUALIFIED_DIVIDENDS_ROW;
      case "ReinvestedUnqualifiedDividendsRow": return REINVESTED_UNQUALIFIED_DIVIDENDS_ROW;
      case "ReinvestedCapitalGainDistributionsRow": return REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW;
      case "TotalDistributionsRow": return TOTAL_DISTRIBUTIONS_ROW;
      case "CostBasisDividerRow": return COST_BASIS_DIVIDER_ROW;
      case "SoldInvestedRow": return SOLD_INVESTED_ROW;
      case "StartCostBasisRow": return START_COST_BASIS_ROW;
      case "EndCostBasisRow": return END_COST_BASIS_ROW;
      case "RealizedGainRow": return REALIZED_GAIN_ROW;
      case "UnrealizedGainRow": return UNREALIZED_GAIN_ROW;
      case "EndBalanceDividerRow": return END_BALANCE_DIVIDER_ROW;
      case "EndBalanceRow": return END_BALANCE_ROW;
      default: return null;
    }
  }

}

const ACCOUNT_ROW = RowType.ACCOUNT_ROW;
const SYMBOL_ROW = RowType.SYMBOL_ROW;
const START_DATE_ROW = RowType.START_DATE_ROW;
const END_DATE_ROW = RowType.END_DATE_ROW;
const START_BALANCE_ROW = RowType.START_BALANCE_ROW;
const IDENTIFIER_DIVIDER_ROW = RowType.IDENTIFIER_DIVIDER_ROW;
const TOTAL_RETURN_ROW = RowType.TOTAL_RETURN_ROW;
const CAPITAL_APPRECIATION_ROW = RowType.CAPITAL_APPRECIATION_ROW;
const INTEREST_ROW = RowType.INTEREST_ROW;
const QUALIFIED_DIVIDENDS_ROW = RowType.QUALIFIED_DIVIDENDS_ROW;
const UNQUALIFIED_DIVIDENDS_ROW = RowType.UNQUALIFIED_DIVIDENDS_ROW;
const CAPITAL_GAIN_DISTRIBUTIONS_ROW = RowType.CAPITAL_GAIN_DISTRIBUTIONS_ROW;
const REINVESTED_INTEREST_ROW = RowType.REINVESTED_INTEREST_ROW;
const REINVESTED_QUALIFIED_DIVIDENDS_ROW = RowType.REINVESTED_QUALIFIED_DIVIDENDS_ROW;
const REINVESTED_UNQUALIFIED_DIVIDENDS_ROW = RowType.REINVESTED_UNQUALIFIED_DIVIDENDS_ROW;
const REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW = RowType.REINVESTED_CAPITAL_GAIN_DISTRIBUTIONS_ROW;
const TOTAL_DISTRIBUTIONS_ROW = RowType.TOTAL_DISTRIBUTIONS_ROW;
const COST_BASIS_DIVIDER_ROW = RowType.COST_BASIS_DIVIDER_ROW;
const SOLD_INVESTED_ROW = RowType.SOLD_INVESTED_ROW;
const START_COST_BASIS_ROW = RowType.START_COST_BASIS_ROW;
const END_COST_BASIS_ROW = RowType.END_COST_BASIS_ROW;
const REALIZED_GAIN_ROW = RowType.REALIZED_GAIN_ROW;
const UNREALIZED_GAIN_ROW = RowType.UNREALIZED_GAIN_ROW;
const END_BALANCE_DIVIDER_ROW = RowType.END_BALANCE_DIVIDER_ROW;
const END_BALANCE_ROW = RowType.END_BALANCE_ROW;



// custom <t_f_holding_period_balance>
// end <t_f_holding_period_balance>
