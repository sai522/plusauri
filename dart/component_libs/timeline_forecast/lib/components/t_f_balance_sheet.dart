library t_f_balance_sheet;
import 'dart:async';
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/models/common.dart' hide Point;
import 'package:plus/models/forecast.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/composite_table.dart';
import 'package:timeline_forecast/current_dollars.dart';
import 'package:timeline_forecast/timeline_model.dart';
import 'package:timeline_forecast/year_axis.dart';
import 'package:tooltip/components/tooltip.dart';
import 't_f_holding_period_balance.dart';

// custom <additional imports>

// end <additional imports>


final _logger = new Logger("tFBalanceSheet");

@CustomTag("plus-t-f-balance-sheet")
class TFBalanceSheet extends PolymerElement {
  HtmlElement get container => _container;
  @observable String title;
  @observable String year;

  TFBalanceSheet.created() : super.created() {
    _logger.fine('TFBalanceSheet created sr => $shadowRoot');
    // custom <TFBalanceSheet created>
    // end <TFBalanceSheet created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFBalanceSheet domReady with sr => $shadowRoot');
    // custom <TFBalanceSheet domReady>
    // end <TFBalanceSheet domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFBalanceSheet ready with sr => $shadowRoot');
    // custom <TFBalanceSheet ready>
    // end <TFBalanceSheet ready>

  }

  @override
  void attached() {
    // custom <TFBalanceSheet pre-attached>
    // end <TFBalanceSheet pre-attached>

    super.attached();
    _logger.fine('TFBalanceSheet attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFBalanceSheet attached>

    _container = $['container'];
    _balanceSheetTable = $['balance-sheet-table'];
    _titleElement = $['title'];

    // end <TFBalanceSheet attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFBalanceSheet)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFBalanceSheet>

  collapseAll() => _compositeTable.collapseAll();
  expandAll() => _compositeTable.expandAll();

  static final _numCells = 6;

  get _netWorthLabel => 'Net Worth';
  get _totalAssetLabel => 'Total Assets';
  get _totalHoldingAssetLabel => 'Total Security Assets';
  get _totalNonholdingAssetLabel => 'Total Non-Security Assets';
  get _totalLiabilityLabel => 'Total Liabilities';
  get _otherAccountGeneral => '*Generic Balance*';
  get _excessReservesLabel => 'Reserves';
  get _deficitReservesLabel => 'Deficit';

  get _inCurrentDollarsLabel => '<span>Showing Current Dollars</span>';
  get _inFutureDollarsLabel => '<span>Showing Future Dollars</span>';

  _accountIndex(String account) => 'ACCOUNT:$account';
  _assetIndex(String asset) => 'ASSET:$asset';
  _holdingIndex(String account, String holding) => 'HOLDING:$account$holding';
  _holdingOtherIndex(String account) => 'HOLDING:OTHER:$account';
  _liabilityIndex(String liability) => 'LIABILITY:$liability';
  _dateIndex() => 'DATE_ROW';

  _getHoldingLabel(CompositeRow row) => row.cells[_labelCellIndex];

  _initializeTable() {
    final dividers = new Set();

    int divider = 1;
    _balanceSheetTable.createTBody();
    _compositeTable = new CompositeTable(_balanceSheetTable);

    addDivider([CompositeRow parent]) {
      final result = ((parent == null) ? _compositeTable.addTopRow(
          'divider ${divider++}') : _compositeTable.addChildRow(parent,
          'divider ${divider++}'))
          ..addColumns(1)
          ..cellContents(_labelCellIndex, '<hr>')
          ..cells[0].attributes['colspan'] = '$_numColumns';
      dividers.add(result);
      return result;
    }

    final dateHeader = _compositeTable.addTopRow(_dateIndex())
        ..addColumns(_numColumns)
        ..cells[_labelCellIndex].children =
        [
          createCollapseIcon(), createExpandIcon(), createCurrentDollarsIcon(), new Element.html(_inFutureDollarsLabel)
                                             ]
        ..cellContents(_startCellIndex, '__/__/__')
        ..cellContents(_endCellIndex, '__/__/__')
        ..addClass('header')
        ..addClass('date_row');

    {
      final cellWithIcons = dateHeader.cells[_labelCellIndex];
      cellWithIcons.children[0].onClick.listen((_) =>
          _compositeTable.collapseAll());
      cellWithIcons.children[1].onClick.listen((_) => _compositeTable.expandAll(
          ));
      cellWithIcons.children[2].onClick.listen((_) {
        if (_currentDollarsToggler != null) {
          _currentDollarsToggler.toggle();
          _displayModel();
          if (_currentDollarsToggler.showingCurrentDollars) {
            cellWithIcons.children[2].classes
                ..remove('fa-fast-backward')
                ..add('fa-fast-forward');
            cellWithIcons.children[3].innerHtml = _inCurrentDollarsLabel;
          } else {
            cellWithIcons.children[2].classes
                ..remove('fa-fast-forward')
                ..add('fa-fast-backward');
            cellWithIcons.children[3].innerHtml = _inFutureDollarsLabel;
          }
        }
      });
    }

    addDivider();

    _netWorthRow = _compositeTable.addTopRow(_netWorthLabel,
        (TableRowElement row) => new BalanceSheetRow(row, _netWorthLabel))
        ..addClass('header');

    addDivider();

    _totalAssetRow = _compositeTable.addTopRow(_totalAssetLabel,
        (TableRowElement row) => new BalanceSheetRow(row, _totalAssetLabel))
      ..cellChildElement(_labelCellIndex, createRowCollapser(_totalAssetLabel))
      ..addClass('header');

    attachExpandHandler(_totalAssetRow);

    addDivider(_totalAssetRow);

    _totalHoldingAssetRow = _compositeTable.addChildRow(_totalAssetRow,
        _totalHoldingAssetLabel,
        (TableRowElement row) => new HoldingRow(row, title, '*', '*'))
        ..addColumns(_numColumns)
      ..cellChildElement(_labelCellIndex, createRowCollapser(_totalHoldingAssetLabel))
      ..addClass('header');

    attachExpandHandler(_totalHoldingAssetRow);

    _balanceSheetModel.visitAccounts((String accountName, int numHoldings) {
      final bool hasSymbolHoldings = numHoldings > 0;
      final accountIndex = _accountIndex(accountName);
      final iconifiedName = '$accountName';
      final accountRow = _compositeTable
        .addChildRow(_totalHoldingAssetRow, accountIndex,
            (TableRowElement row) => new HoldingRow(row, title, accountName, '*'))
        ..addColumns(_numColumns)
        ..addClass('account');

      List childrenRows = [];

      if(hasSymbolHoldings) {
        accountRow.cellChildElement(_labelCellIndex, createRowCollapser(iconifiedName));
        attachExpandHandler(accountRow);
        final label = _holdingOtherIndex(accountName);
        final holdingOtherRow = _compositeTable.addChildRow(accountRow, label,
            (TableRowElement row) =>
            new HoldingRow(row, title, accountName, _otherAccountGeneral)
            ..addClass('holding'));
      } else {
        accountRow.cellContents(_labelCellIndex, iconifiedName);
      }

      _balanceSheetModel.visitAccountHoldings(accountName,
          (HoldingKey holdingKey, double startValue, double endValue) {
        final label = _holdingIndex(holdingKey.accountName,
            holdingKey.holdingName);
        final iconifiedHoldingName = '${holdingKey.holdingName}';
        final holdingRow = _compositeTable.addChildRow(accountRow, label,
            (TableRowElement row) =>
            new HoldingRow(row, title, holdingKey.accountName,
                holdingKey.holdingName)
            ..cellContents(_labelCellIndex, iconifiedHoldingName)
            ..addClass('holding'));
      });

    });

    addDivider(_totalHoldingAssetRow);

    _totalNonholdingAssetRow = _compositeTable.addChildRow(_totalAssetRow,
        _totalNonholdingAssetLabel,
        (TableRowElement row) => new BalanceSheetRow(row, _totalNonholdingAssetLabel))
      ..cellChildElement(_labelCellIndex, createRowCollapser(_totalNonholdingAssetLabel))
      ..addClass('header');

    addDivider(_totalNonholdingAssetRow);
    attachExpandHandler(_totalNonholdingAssetRow);

    _balanceSheetModel.visitAssets((String assetName, double start, double end) {
      final label = _assetIndex(assetName);
      _compositeTable.addChildRow(_totalNonholdingAssetRow,
          label,
          (TableRowElement row) => new BalanceSheetRow(row, label))
        ..cellContents(_labelCellIndex, assetName)
        ..addClass('asset');
    });

    addDivider();

    _totalLiabilityRow = _compositeTable.addTopRow(_totalLiabilityLabel,
        (TableRowElement row) => new BalanceSheetRow(row, _totalLiabilityLabel))
      ..cellChildElement(_labelCellIndex, createRowCollapser(_totalLiabilityLabel))
      ..addClass('header');

    attachExpandHandler(_totalLiabilityRow);
    addDivider();

    _annualForecastModel.visitExtendedLiabilities(
      _currentDollarsToggler.inflation,
      (String liabilityName, double start, double end, bool isExtended) {
        final label = _liabilityIndex(liabilityName);
        _compositeTable.addChildRow(_totalLiabilityRow, label,
            (TableRowElement row) => new BalanceSheetRow(row, liabilityName))
          ..addClass('liability');
      });

    addIndentClass(CompositeRow row) {
      if (!dividers.contains(row)) {
        row.cells[_labelCellIndex].classes.add('indent-${row.indentLevel}');
      }
    }

    _reservesRow = _compositeTable.addTopRow('',
        (TableRowElement row) => new BalanceSheetRow(row, ''))
      ..addClass('header');

    _compositeTable.visit(addIndentClass);

  }

  _setNoValueClass(CompositeRow row, double startValue, double endValue) {
    if(startValue == 0.0 && endValue == 0.0) {
      row.addClass('no-value');
    } else {
      row.removeClass('no-value');
    }
  }

  _displayModel() {
    _compositeTable.getRow(_dateIndex())
      ..cellContents(_startCellIndex, dateFormat(_periodRange.start.dateTime))
      ..cellContents(_endCellIndex, dateFormat(_periodRange.end.dateTime));

    final totalLiabilities = new PeriodBalance.empty(_periodRange.start.year);

    _balanceSheetModel.visitAssets((String assetName, double start, double end) {
      _compositeTable.getRow(_assetIndex(assetName))
        ..setStartValue(_balanceSheetModel.startDate, start, _currentDollarsToggler)
        ..setEndValue(_balanceSheetModel.endDate, end, _currentDollarsToggler);
    });

    _annualForecastModel.visitExtendedLiabilities(
      _currentDollarsToggler.inflation,
      (String liabilityName, double start, double end, bool isExtended) {
        totalLiabilities.start.value += start;
        totalLiabilities.end.value += end;
      final therow = _compositeTable.getRow(_liabilityIndex(liabilityName));
      _compositeTable.getRow(_liabilityIndex(liabilityName))
        ..setStartValue(_balanceSheetModel.startDate, start, _currentDollarsToggler)
        ..setEndValue(_balanceSheetModel.endDate, end, _currentDollarsToggler);
    });

    _balanceSheetModel.visitAccounts((String accountName, int numHoldings) {
      bool hasSymbolHoldings = numHoldings > 0;
      _balanceSheetModel.visitAccountOtherHoldings(accountName,
          (HoldingKey holdingKey, double startValue, double endValue) {
        if(hasSymbolHoldings) {
          final otherHoldingsRow =
            _compositeTable.getRow(_holdingOtherIndex(accountName))
            ..setStartValue(_balanceSheetModel.startDate, startValue, _currentDollarsToggler)
            ..setEndValue(_balanceSheetModel.endDate, endValue, _currentDollarsToggler)
            ..setHPBFactory(() =>
                _balanceSheetModel.createHoldingPeriodBalance(
                    holdingKey.accountName, holdingKey.holdingName));

          if(startValue == 0.0 && endValue == 0.0) {
            otherHoldingsRow.hide();
          } else {
            otherHoldingsRow.show();
          }
        }
      });

      _balanceSheetModel.visitAccountHoldings(accountName,
          (HoldingKey holdingKey, double startValue, double endValue) {
        var holdingRow = _compositeTable
          .getRow(_holdingIndex(holdingKey.accountName, holdingKey.holdingName))
          ..setStartValue(_balanceSheetModel.startDate, startValue, _currentDollarsToggler)
          ..setEndValue(_balanceSheetModel.endDate, endValue, _currentDollarsToggler)
          ..setHPBFactory(() =>
              _balanceSheetModel.createHoldingPeriodBalance(
                  holdingKey.accountName, holdingKey.holdingName));
        _setNoValueClass(holdingRow, startValue, endValue);
      });

      _balanceSheetModel.visitAccountTotalHoldings(accountName,
          (HoldingKey totalHoldingKey, double startValue, double endValue) {

        final holdingRow = _compositeTable.getRow(_accountIndex(accountName))
          ..setStartValue(_balanceSheetModel.startDate, startValue, _currentDollarsToggler)
          ..setEndValue(_balanceSheetModel.endDate, endValue, _currentDollarsToggler)
          ..setHPBFactory(() => _balanceSheetModel
              .createAccountHoldingPeriodBalance(accountName));

        _setNoValueClass(holdingRow, startValue, endValue);
      });

    });


    final totalHoldingAssets = _balanceSheetModel.totalHoldings;
    final totalNonHoldingAssets = _balanceSheetModel.totalNonHoldingAssets;
    final totalAssets = totalHoldingAssets + totalNonHoldingAssets;
    //    final totalLiabilities = _balanceSheetModel.totalLiabilities;
    final totalReserves = _balanceSheetModel.reserves;


    _totalHoldingAssetRow
      ..setStartValue(_balanceSheetModel.startDate, totalHoldingAssets.startValue, _currentDollarsToggler)
      ..setEndValue(_balanceSheetModel.endDate, totalHoldingAssets.endValue, _currentDollarsToggler)
      ..setHPBFactory(() => _balanceSheetModel.createTotalHoldingPeriodBalance());

    _totalNonholdingAssetRow.setModel(totalNonHoldingAssets, _currentDollarsToggler);
    _totalAssetRow.setModel(totalAssets, _currentDollarsToggler);
    _totalLiabilityRow.setModel(totalLiabilities, _currentDollarsToggler);
    _reservesRow
      ..setModel(totalReserves, _currentDollarsToggler)
      ..cells[_labelCellIndex].innerHtml =
      (totalReserves.end.value < 0.0)? _deficitReservesLabel : _excessReservesLabel;

    final netAssets = totalAssets - totalLiabilities + totalReserves;

    _compositeTable.getRow(_netWorthLabel)
      ..setStartValue(_balanceSheetModel.startDate, netAssets.startValue, _currentDollarsToggler)
      ..setEndValue(_balanceSheetModel.endDate, netAssets.endValue, _currentDollarsToggler);
  }

  setModel(IAnnualForecastModel annualForecastModel, CurrentDollarsToggler
      currentDollarsToggler) {
    _annualForecastModel = annualForecastModel;
    _balanceSheetModel = annualForecastModel.balanceSheetModel;
    final bsYear = _balanceSheetModel.year;
    year = '${bsYear}';
    _periodRange = fiscalRange(bsYear);
    _startDateValue = dateValue(_periodRange.start, 0.0);
    _endDateValue = dateValue(_periodRange.end, 0.0);
    _currentDollarsToggler = currentDollarsToggler;
    if (_balanceSheetTable.tBodies.length == 0) _initializeTable();
    _displayModel();
  }

  moneyDisplayStart(double value) => moneyFormat(
      _currentDollarsToggler.showDollars(_startDateValue..value = value), false);

  moneyDisplayEnd(double value) => moneyFormat(
      _currentDollarsToggler.showDollars(_endDateValue..value = value), false);

  // end <class TFBalanceSheet>
  IAnnualForecastModel _annualForecastModel;
  IBalanceSheetModel _balanceSheetModel;
  HtmlElement _container;
  DateRange _periodRange;
  DateValue _startDateValue;
  DateValue _endDateValue;
  CurrentDollarsToggler _currentDollarsToggler;
  TableElement _balanceSheetTable;
  CompositeTable _compositeTable;
  BalanceSheetRow _netWorthRow;
  BalanceSheetRow _totalAssetRow;
  HoldingRow _totalHoldingAssetRow;
  BalanceSheetRow _totalNonholdingAssetRow;
  BalanceSheetRow _totalLiabilityRow;
  BalanceSheetRow _reservesRow;
  HtmlElement _titleElement;
  HtmlElement _totalAssetExpander;
  HtmlElement _totalHoldingAssetExpander;
  HtmlElement _totalNonholdingAssetExpander;
  HtmlElement _totalLiabilityExpander;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}


class BalanceSheetRow extends CompositeRow {
  // custom <class BalanceSheetRow>

  BalanceSheetRow(TableRowElement row, String label) : super(row) {
    addColumns(_numColumns);
    cellContents(_labelCellIndex, label);
  }

  setStartValue(Date startDate, double startValue, CurrentDollarsToggler toggler) =>
    cellContents(_startCellIndex,
        moneyFormat(toggler.showDollarsPair(startDate, startValue), false));

  setEndValue(Date endDate, double endValue, CurrentDollarsToggler toggler) =>
    cellContents(_endCellIndex,
        moneyFormat(toggler.showDollarsPair(endDate, endValue), false));

  setModel(PeriodBalance model, CurrentDollarsToggler toggler) {

    cellContents(_startCellIndex,
        moneyFormat(
          toggler.showDollars(model.start), false));

    cellContents(_endCellIndex,
        moneyFormat(
          toggler.showDollars(model.end), false));

  }

  // end <class BalanceSheetRow>
}

class HoldingRow extends BalanceSheetRow {
  StreamSubscription<MouseEvent> get onClickSubscription => _onClickSubscription;
  // custom <class HoldingRow>

  void setHPBFactory(HPBFactory hpbFactory) {

    if(_onClickSubscription != null) _onClickSubscription.cancel();
    _onClickSubscription = row.onClick.listen((me) {
          _holdingPeriodBalance = hpbFactory();
          final year = _holdingPeriodBalance.year;

          final tooltip = (new Element.tag('plus-tooltip') as Tooltip)
            ..addTipContainerClass('holding-row-container')
            ..addTipContentClass('holding-row-tip-content')
            ..addHeaderClass('holding-row-header')
            ..headerContentElement =
            (new Element.html("<span>Holding Period Balance ($_scenarioName : $year)</span>")
                ..classes.add('holding-period-title-span'));
          
          tooltip.onAttached((Tooltip ttip) {
            ttip
            ..tipChildren = 
                [                               
                 (new Element.tag('plus-t-f-holding-period-balance')
                   as TFHoldingPeriodBalance)
                   ..onAttached((TFHoldingPeriodBalance tfhpb) =>
                       tfhpb.setModel(_account, _symbol, _holdingPeriodBalance))
                       ]  
            ..show(me, const Point(10,10));
          });
          
          document.body.children.add(tooltip);
        });
  }

  HoldingRow(TableRowElement row, this._scenarioName, this._account,
      String symbol) : super(row, symbol),
                       _symbol = symbol;

  // end <class HoldingRow>
  String _scenarioName;
  String _account;
  String _symbol;
  HoldingPeriodBalance _holdingPeriodBalance;
  StreamSubscription<MouseEvent> _onClickSubscription;
}


// custom <t_f_balance_sheet>

final _labelCellIndex = 0;
final _startCellIndex = 3;
final _endCellIndex = 4;
final _noteCellIndex = 5;
final _numColumns = 6;

typedef HoldingPeriodBalance HPBFactory();


// end <t_f_balance_sheet>
