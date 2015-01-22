library t_f_annual_component_toggler;
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/timeline_enums.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFAnnualComponentToggler");

@CustomTag("plus-t-f-annual-component-toggler")
class TFAnnualComponentToggler extends PolymerElement {
  @observable final Set toggledOnSet = new Set.from(AnnualComponentType.values);

  TFAnnualComponentToggler.created() : super.created() {
    _logger.fine('TFAnnualComponentToggler created sr => $shadowRoot');
    // custom <TFAnnualComponentToggler created>
    // end <TFAnnualComponentToggler created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFAnnualComponentToggler domReady with sr => $shadowRoot');
    // custom <TFAnnualComponentToggler domReady>
    // end <TFAnnualComponentToggler domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFAnnualComponentToggler ready with sr => $shadowRoot');
    // custom <TFAnnualComponentToggler ready>
    // end <TFAnnualComponentToggler ready>

  }

  @override
  void attached() {
    // custom <TFAnnualComponentToggler pre-attached>
    // end <TFAnnualComponentToggler pre-attached>

    super.attached();
    _logger.fine('TFAnnualComponentToggler attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFAnnualComponentToggler attached>
    _balanceSheetButton = $['balance-sheet']
      ..onClick.listen((e) => _buttonClicked(e, BALANCE_SHEET_COMPONENT));
    _incomeStatementButton = $['income-statement']
      ..onClick.listen((e) => _buttonClicked(e, INCOME_STATEMENT_COMPONENT));
    _taxSummaryButton = $['tax-summary']
      ..onClick.listen((e) => _buttonClicked(e, TAX_SUMMARY_COMPONENT));
    _liquidationSummaryButton = $['liquidation-summary']
      ..onClick.listen((e) => _buttonClicked(e, LIQUIDATION_SUMMARY_COMPONENT));
    // end <TFAnnualComponentToggler attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFAnnualComponentToggler)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFAnnualComponentToggler>

  _changeEnabledState(Element elm, bool state) {
  }

  _showEnabledStates() {
   _changeEnabledState(_balanceSheetButton, toggledOnSet.contains(BALANCE_SHEET_COMPONENT));
   _changeEnabledState(_incomeStatementButton, toggledOnSet.contains(INCOME_STATEMENT_COMPONENT));
   _changeEnabledState(_taxSummaryButton, toggledOnSet.contains(TAX_SUMMARY_COMPONENT));
   _changeEnabledState(_liquidationSummaryButton, toggledOnSet.contains(LIQUIDATION_SUMMARY_COMPONENT));
  }

  _selectOnly(MouseEvent evt, AnnualComponentType singleSelection) {
    final priorValues = new Set.from(toggledOnSet);
    toggledOnSet.clear();
    toggledOnSet.add(singleSelection);
    notifyPropertyChange(#toggledOnSet, priorValues, toggledOnSet);
    evt.stopPropagation();
    _updateAndNotify(priorValues);
  }

  _toggled(MouseEvent evt, AnnualComponentType annualComponentType) {
    final priorValues = new Set.from(toggledOnSet);
    if(toggledOnSet.contains(annualComponentType)) {
      toggledOnSet.remove(annualComponentType);
    } else {
      toggledOnSet.add(annualComponentType);
    }
    evt.stopPropagation();
    _updateAndNotify(priorValues);
  }

  _buttonClicked(MouseEvent evt, AnnualComponentType annualComponentType) {
    if(evt.shiftKey) {
      _selectOnly(evt, annualComponentType);
    } else {
      _toggled(evt, annualComponentType);
    }
  }

  _updateAndNotify(priorValues) {
    _showEnabledStates();
    notifyPropertyChange(#toggledOnSet, priorValues, toggledOnSet);
    deliverChanges();
  }

  // end <class TFAnnualComponentToggler>
  Element _balanceSheetButton;
  Element _incomeStatementButton;
  Element _taxSummaryButton;
  Element _liquidationSummaryButton;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <t_f_annual_component_toggler>
// end <t_f_annual_component_toggler>
