library t_f_income_statement;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/date_range.dart';
import 'package:plus/finance.dart';
import 'package:plus/models/forecast.dart';
import 'package:plus/models/income_statement.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/composite_table.dart';
import 'package:timeline_forecast/current_dollars.dart';
import 'package:timeline_forecast/timeline_model.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFIncomeStatement");

@CustomTag("plus-t-f-income-statement")
class TFIncomeStatement extends PolymerElement {
  HtmlElement get container => _container;
  @observable String year;

  TFIncomeStatement.created() : super.created() {
    _logger.fine('TFIncomeStatement created sr => $shadowRoot');
    // custom <TFIncomeStatement created>
    // end <TFIncomeStatement created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFIncomeStatement domReady with sr => $shadowRoot');
    // custom <TFIncomeStatement domReady>
    // end <TFIncomeStatement domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFIncomeStatement ready with sr => $shadowRoot');
    // custom <TFIncomeStatement ready>
    // end <TFIncomeStatement ready>

  }

  @override
  void attached() {
    // custom <TFIncomeStatement pre-attached>
    // end <TFIncomeStatement pre-attached>

    super.attached();
    _logger.fine('TFIncomeStatement attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFIncomeStatement attached>
    _incomeExpenseTable = $['income-expense-table'];
    _container = $['container'];
    // end <TFIncomeStatement attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFIncomeStatement)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFIncomeStatement>

  double _itemTotal(Map items, String income) {
    IEItem iEItem = items[income];
    return iEItem == null? 0.0 : iEItem.details.sum;
  }

  get _netIncomeLabel => 'Net Income';
  get _totalIncomeLabel => 'Total Incomes';
  get _totalExpenseLabel => 'Total Expenses';
  get _columnHeadersLabel => 'Column Headers';

  get _labelCellIndex => 0;
  get _flowCellIndex => 1;
  get _pctTotalCellIndex => 2;
  get _numColumns => 3;

  _incomeIndex(String income) => 'INCOME:$income';
  _expenseIndex(String expense) => 'EXPENSE:$expense';

  _initializeTable() {

    final dividers = new Set();
    int divider = 1;
    _incomeExpenseTable.createTBody();
    _compositeTable = new CompositeTable(_incomeExpenseTable);

    getExpander(row) => row.cells[_labelCellIndex].children[0];

    attachIncomeHandler(CompositeRow row) {
      final incomeRowLabel = row.cells[_labelCellIndex];
      incomeRowLabel.onMouseEnter.listen((_) => print('Entered ${incomeRowLabel.innerHtml}'));
    }

    attachExpenseHandler(CompositeRow row) {
      final expenseRowLabel = row.cells[_labelCellIndex];
      expenseRowLabel.onMouseEnter.listen((_) => print('Entered ${expenseRowLabel.innerHtml}'));
    }

    addDivider([CompositeRow parent]) {
      final result = ((parent == null)?
          _compositeTable.addTopRow('divider ${divider++}') :
          _compositeTable.addChildRow(parent, 'divider ${divider++}'))
        ..addColumns(1)
        ..cellContents(_labelCellIndex, '<hr>')
        ..cells[0].attributes['colspan'] = '$_numColumns';
      dividers.add(result);
      return result;
    }

    _compositeTable.addTopRow(_columnHeadersLabel)
      ..addColumns(_numColumns)
      ..cellContents(_flowCellIndex, 'Period Flows')
      ..cellContents(_pctTotalCellIndex, '% Total')
      ..addClass('net-header');

    addDivider();

    _compositeTable.addTopRow(_netIncomeLabel)
      ..addColumns(_numColumns)
      ..cellContents(_labelCellIndex, _netIncomeLabel)
      ..addClass('net-header');

    addDivider();

    {
      bool incomesPresent = _model.numIncomes > 0;
      final totalIncomeRow = incomesPresent ?
      (_compositeTable.addTopRow(_totalIncomeLabel)
          ..addColumns(_numColumns)
          ..cellChildElement(_labelCellIndex, createRowCollapser(_totalIncomeLabel))
          ..addClass('net-header')) :
      (_compositeTable.addTopRow(_totalIncomeLabel)
          ..addColumns(_numColumns)
          ..cellContents(_labelCellIndex, _totalIncomeLabel)
          ..addClass('net-header'));

      if(incomesPresent) {
        attachExpandHandler(totalIncomeRow);
        addDivider();

        _model.visitIncomes((String incomeName, double amount) {
          final row = _compositeTable.addChildRow(totalIncomeRow,
              _incomeIndex(incomeName))
            ..addColumns(_numColumns)
            ..cellContents(_labelCellIndex, incomeName)
            ..addClass('income');
          attachIncomeHandler(row);
        });
      }

      addDivider(totalIncomeRow);
    }

    {
      bool expensesPresent = _model.numExpenses > 0;
      final totalExpenseRow = expensesPresent ?
      (_compositeTable.addTopRow(_totalExpenseLabel)
          ..addColumns(_numColumns)
          ..cellChildElement(_labelCellIndex, createRowCollapser(_totalExpenseLabel))
          ..addClass('net-header')) :
      (_compositeTable.addTopRow(_totalExpenseLabel)
          ..addColumns(_numColumns)
          ..cellContents(_labelCellIndex, _totalExpenseLabel)
          ..addClass('net-header'));

      if(expensesPresent) {
        attachExpandHandler(totalExpenseRow);
        addDivider();

        _model.visitExpenses((String expenseName, double amount) {
          final row = _compositeTable.addChildRow(totalExpenseRow,
              _expenseIndex(expenseName))
            ..addColumns(_numColumns)
            ..cellContents(_labelCellIndex, expenseName)
            ..addClass('expense');
          attachExpenseHandler(row);
        });
      }
    }

    addIndentClass(CompositeRow row) {
      if(!dividers.contains(row)) {
        row.cells[_labelCellIndex].classes.add('indent-${row.indentLevel}');
      }
    }

    _compositeTable.visit(addIndentClass);

  }

  _displayModel() {

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double netIncome = 0.0;

    _model.visitIncomes((String incomeName, double amount) {
      final row = _compositeTable.getRow(_incomeIndex(incomeName));
      row.cellContents(_flowCellIndex, moneyFormat(amount, false));
      totalIncome += amount;
      netIncome += amount;
    });

    _model.visitIncomes((String incomeName, double amount) {
      final row = _compositeTable.getRow(_incomeIndex(incomeName));
      if(amount == 0.0) {
        row.hide();
      } else {
        row.cellContents(_pctTotalCellIndex,
            totalIncome != 0.0? percentFormat((amount/totalIncome).abs(), false):'');
        row.show();
      }
    });

    {
      final row = _compositeTable.getRow(_totalIncomeLabel);
      row.cellContents(_flowCellIndex, moneyFormat(totalIncome, false));
      row.cellContents(_pctTotalCellIndex,
          totalIncome != 0.0? percentFormat(1.0, false) : '');
    }

    _model.visitExpenses((String expenseName, double amount) {
      final row = _compositeTable.getRow(_expenseIndex(expenseName));
      row.cellContents(_flowCellIndex, moneyFormat(amount, false));
      totalExpense += amount;
      netIncome += amount;
    });

    _model.visitExpenses((String expenseName, double amount) {
      final row = _compositeTable.getRow(_expenseIndex(expenseName));
      if(amount == 0.0) {
        row.hide();
      } else {
        row.cellContents(_pctTotalCellIndex,
            totalExpense != 0.0?
            percentFormat(amount/totalExpense, false):'');
        row.show();
      }
    });

    {
      final row = _compositeTable.getRow(_totalExpenseLabel);
      row.cellContents(_flowCellIndex, moneyFormat(totalExpense, false));
      row.cellContents(_pctTotalCellIndex,
          totalExpense != 0.0? percentFormat(1.0, false) : '');
    }

    {
      final row = _compositeTable.getRow(_netIncomeLabel);
      row.cellContents(_flowCellIndex, moneyFormat(netIncome, false));
    }
  }

  setModel(IIncomeStatementModel incomeStatementModel,
      CurrentDollarsToggler currentDollarsToggler) {
    _model = incomeStatementModel;
    _currentDollarsToggler = currentDollarsToggler;
    year = '${incomeStatementModel.year}';

    if(_compositeTable == null) {
      _initializeTable();
    }

    _displayModel();
  }

  // end <class TFIncomeStatement>
  IIncomeStatementModel _model;
  HtmlElement _container;
  CurrentDollarsToggler _currentDollarsToggler;
  TableElement _incomeExpenseTable;
  CompositeTable _compositeTable;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <t_f_income_statement>
// end <t_f_income_statement>
