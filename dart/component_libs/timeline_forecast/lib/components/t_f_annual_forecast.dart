library t_f_annual_forecast;
import 'dart:async';
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:plus/models/forecast.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/timeline_enums.dart';
import 'package:timeline_forecast/timeline_model.dart';
import 't_f_annual_component_toggler.dart';
import 't_f_balance_sheet.dart';
import 't_f_income_statement.dart';
import 't_f_liquidation_summary.dart';
import 't_f_tax_summary.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFAnnualForecast");

@CustomTag("plus-t-f-annual-forecast")
class TFAnnualForecast extends PolymerElement {
  @observable String annualForecastTitle;
  @observable int year = 0;

  TFAnnualForecast.created() : super.created() {
    _logger.fine('TFAnnualForecast created sr => $shadowRoot');
    // custom <TFAnnualForecast created>
    // end <TFAnnualForecast created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFAnnualForecast domReady with sr => $shadowRoot');
    // custom <TFAnnualForecast domReady>
    // end <TFAnnualForecast domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFAnnualForecast ready with sr => $shadowRoot');
    // custom <TFAnnualForecast ready>
    // end <TFAnnualForecast ready>

  }

  @override
  void attached() {
    // custom <TFAnnualForecast pre-attached>
    // end <TFAnnualForecast pre-attached>

    super.attached();
    _logger.fine('TFAnnualForecast attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFAnnualForecast attached>

    _header.onClick.listen((_) => _toggle());

    // end <TFAnnualForecast attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFAnnualForecast)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFAnnualForecast>

  get _contents => $['contents'];
  get _header => $['header'];
  get _tFBalanceSheet => $['balance-sheet'];
  get _tFIncomeStatement => $['income-statement'];
  get _tFTaxSummary => $['tax-summary'];
  get _tFLiquidationSummary => $['liquidation-summary'];

  setModel(final annualForecastModel) {

     _balanceSheetHider = new _ComponentHider(_tFBalanceSheet.container);
     _incomeStatementHider = new _ComponentHider(_tFIncomeStatement.container);
     _taxSummaryHider = new _ComponentHider(_tFTaxSummary.container);
     _liquidationSummaryHider = new _ComponentHider(_tFLiquidationSummary.container);

    _annualForecastModel = annualForecastModel;
    final cdt = _annualForecastModel.currentDollarsToggler;
    _annualForecastModel = annualForecastModel;
    year = annualForecastModel.year;

    final incomeStatementModel = _annualForecastModel.incomeStatementModel;
    incomeStatementModel.visitObligatoryExpenses(
      (String flowName, double amount) {
        print('Found *obligatory* flow $flowName => $amount');
      });

    _tFIncomeStatement
      .setModel(_annualForecastModel.incomeStatementModel, cdt);
    _tFBalanceSheet
      ..title = annualForecastModel.title
      ..setModel(_annualForecastModel, cdt);
    _tFLiquidationSummary
      .setModel(_annualForecastModel.liquidationSummaryModel, cdt);
    _tFTaxSummary
      .setModel(_annualForecastModel.taxSummaryModel, cdt, year);
    annualForecastTitle = annualForecastModel.title;
  }

  collapseAll() {
    _tFBalanceSheet.collapseAll();
  }

  setDisplayedComponents(Set<AnnualComponentType> displayedComponents) {
    _balanceSheetHider.changeRequest(
      displayedComponents.contains(BALANCE_SHEET_COMPONENT));
    _incomeStatementHider.changeRequest(
      displayedComponents.contains(INCOME_STATEMENT_COMPONENT));
    _taxSummaryHider.changeRequest(
      displayedComponents.contains(TAX_SUMMARY_COMPONENT));
    _liquidationSummaryHider.changeRequest(
      displayedComponents.contains(LIQUIDATION_SUMMARY_COMPONENT));
  }

  _toggle() {
    if(_contents.style.getPropertyValue('display') == 'none') {
      _contents.style.removeProperty('display');
    } else {
      _contents.style.setProperty('display', 'none');
    }
  }

  // end <class TFAnnualForecast>
  _ComponentHider _balanceSheetHider;
  _ComponentHider _incomeStatementHider;
  _ComponentHider _taxSummaryHider;
  _ComponentHider _liquidationSummaryHider;
  IAnnualForecastModel _annualForecastModel;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}


class _ComponentHider {
  _ComponentHider(this.element) {
    // custom <_ComponentHider>
    // end <_ComponentHider>
  }

  Element element;
  bool isShown = true;
  double computedWidth = 0.0;
  double computedPadding = 0.0;
  static final RegExp pxRegex = new RegExp(r'([\d.]+)px');
  // custom <class ComponentHider>

  changeRequest(bool showComponent) =>
    showComponent? show() : hide();

  hide() => element.style.setProperty('display', 'none');
  show() => element.style.removeProperty('display');

  // end <class ComponentHider>
}


// custom <t_f_annual_forecast>
// end <t_f_annual_forecast>
