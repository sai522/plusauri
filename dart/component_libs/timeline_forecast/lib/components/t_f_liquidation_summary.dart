library t_f_liquidation_summary;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/models/common.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/composite_table.dart';
import 'package:timeline_forecast/current_dollars.dart';
import 'package:timeline_forecast/timeline_model.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFLiquidationSummary");

@CustomTag("plus-t-f-liquidation-summary")
class TFLiquidationSummary extends PolymerElement {
  HtmlElement get container => _container;
  @observable String year;

  TFLiquidationSummary.created() : super.created() {
    _logger.fine('TFLiquidationSummary created sr => $shadowRoot');
    // custom <TFLiquidationSummary created>
    // end <TFLiquidationSummary created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFLiquidationSummary domReady with sr => $shadowRoot');
    // custom <TFLiquidationSummary domReady>
    // end <TFLiquidationSummary domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFLiquidationSummary ready with sr => $shadowRoot');
    // custom <TFLiquidationSummary ready>
    // end <TFLiquidationSummary ready>

  }

  @override
  void attached() {
    // custom <TFLiquidationSummary pre-attached>
    // end <TFLiquidationSummary pre-attached>

    super.attached();
    _logger.fine('TFLiquidationSummary attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFLiquidationSummary attached>
    _liquidationSummaryTable = $['liquidation-summary-table'];
    _container = $['container'];
    // end <TFLiquidationSummary attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFLiquidationSummary)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFLiquidationSummary>

  setModel(ILiquidationSummaryModel liquidationSummaryModel,
      CurrentDollarsToggler currentDollarsToggler) {
    _model = liquidationSummaryModel;
    _currentDollarsToggler = currentDollarsToggler;
    year = '${_model.year}';

    if(_compositeTable == null) {
      _initializeTable();
    }

    _displayModel();
  }

  get _expandIconHtml => '<i class="fa fa-plus-circle"></i>';
  get _collapseIconHtml => '<i class="fa fa-minus-circle"></i>';

  _initializeTable() {
    _liquidationSummaryTable.createTBody();
    _compositeTable = new CompositeTable(_liquidationSummaryTable);
  }

  get _flowAccountNameCellIndex => 0;
  get _flowHoldingNameCellIndex => 1;
  get _flowNameCellIndex => 2;
  get _flowAmountCellIndex => 3;
  get _flowNettedCellIndex => 4;
  get _holdingBalanceCellIndex => 5;

  get _numColumns => 6;
  get _totalCreditsLabel => 'Total Credits';
  get _totalDebitsLabel => 'Total Debits';
  get _columnHeadersLabel => 'Column Headers';

  _displayModel() {
    final dividers = new Set();
    int divider = 1;

    addDivider([CompositeRow parent]) {
      final result = ((parent == null)?
          _compositeTable.addTopRow('divider ${divider++}') :
          _compositeTable.addChildRow(parent, 'divider ${divider++}'))
        ..addColumns(1)
        ..cellContents(_flowAccountNameCellIndex, '<hr>')
        ..cells[0].attributes['colspan'] = '$_numColumns';
      dividers.add(result);
      return result;
    }

    _compositeTable.clear();
    _compositeTable.addTopRow(_columnHeadersLabel)
      ..addColumns(_numColumns)
      ..cellContents(_flowAccountNameCellIndex, 'Account')
      ..cellContents(_flowHoldingNameCellIndex, 'Holding')
      ..cellContents(_flowNameCellIndex, 'In/Out Flow')
      ..cellContents(_flowAmountCellIndex, 'Amount')
      ..cellContents(_flowNettedCellIndex, NetFlowsLabel)
      ..cellContents(_holdingBalanceCellIndex, 'End Balance')
      ..addClass('net-header');

    addDivider();

    var creditTotalRow = _compositeTable.addTopRow(_totalCreditsLabel)
      ..addColumns(_numColumns)
      ..cellContents(_flowAccountNameCellIndex, '$_collapseIconHtml$_totalCreditsLabel')
      ..addClass('net-header');

    double totalCredits = 0.0, totalDebits = 0.0;
    _model.visitCredits(
      (HoldingKey holdingKey, String creditName, double creditAmount, double balance) {
        var row = _compositeTable.addChildRow(creditTotalRow, 'cr-$holdingKey:$creditName')
          ..addColumns(_numColumns)
          ..cellContents(_flowNameCellIndex, creditName)
          ..addClass('credit');

        if(creditName != NetFlowsLabel) {
          row.cellContents(_flowAmountCellIndex, moneyFormat(creditAmount, false));
          totalCredits += creditAmount;
        }

        if(holdingKey != ReserveHolding) {
          row
            ..cellContents(_holdingBalanceCellIndex, moneyFormat(balance, false))
            ..cellContents(_flowAccountNameCellIndex, holdingKey.accountName)
            ..cellContents(_flowHoldingNameCellIndex, holdingKey.holdingName);
        } else {
          row.cellContents(_flowNettedCellIndex, moneyFormat(-creditAmount, false));
        }
        if(creditName == NetFlowsLabel) {
          row.cellContents(_flowNettedCellIndex, moneyFormat(creditAmount, false));
        }
      });

    creditTotalRow.cellContents(_flowAmountCellIndex, moneyFormat(totalCredits, false));

    var debitTotalRow = _compositeTable.addTopRow(_totalDebitsLabel)
      ..addColumns(_numColumns)
      ..cellContents(_flowAccountNameCellIndex, '$_collapseIconHtml$_totalDebitsLabel')
      ..addClass('net-header');

    int i=0;
    _model.visitDebits(
      (HoldingKey holdingKey, String debitName, double debitAmount, double balance) {
        var row = _compositeTable.addChildRow(debitTotalRow, 'db-$i-$holdingKey:$debitName')
          ..addColumns(_numColumns)
          ..cellContents(_flowNameCellIndex, debitName)
          ..addClass('debit');

        if(debitName != NetFlowsLabel) {
          row.cellContents(_flowAmountCellIndex, moneyFormat(debitAmount, false));
          totalDebits += debitAmount;
        }

        if(holdingKey != ReserveHolding) {
          row
            ..cellContents(_holdingBalanceCellIndex, moneyFormat(balance, false))
            ..cellContents(_flowAccountNameCellIndex, holdingKey.accountName)
            ..cellContents(_flowHoldingNameCellIndex, holdingKey.holdingName);
        } else {
          row.cellContents(_flowNettedCellIndex, moneyFormat(-debitAmount, false));
        }

        if(debitName == NetFlowsLabel) {
          row.cellContents(_flowNettedCellIndex, moneyFormat(debitAmount, false));
        }

        i++;
      });

    debitTotalRow.cellContents(_flowAmountCellIndex, moneyFormat(totalDebits, false));
  }

  // end <class TFLiquidationSummary>
  ILiquidationSummaryModel _model;
  HtmlElement _container;
  CurrentDollarsToggler _currentDollarsToggler;
  TableElement _liquidationSummaryTable;
  CompositeTable _compositeTable;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <t_f_liquidation_summary>
// end <t_f_liquidation_summary>
