library t_f_nav_content_selector;
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:quiver/iterables.dart' hide min, max;
import 'package:timeline_forecast/timeline_enums.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFNavContentSelector");

@CustomTag("plus-t-f-nav-content-selector")
class TFNavContentSelector extends PolymerElement {
  @observable NavContentType navContentType;

  TFNavContentSelector.created() : super.created() {
    _logger.fine('TFNavContentSelector created sr => $shadowRoot');
    // custom <TFNavContentSelector created>
    // end <TFNavContentSelector created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFNavContentSelector domReady with sr => $shadowRoot');
    // custom <TFNavContentSelector domReady>
    // end <TFNavContentSelector domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFNavContentSelector ready with sr => $shadowRoot');
    // custom <TFNavContentSelector ready>
    // end <TFNavContentSelector ready>

  }

  @override
  void attached() {
    // custom <TFNavContentSelector pre-attached>
    // end <TFNavContentSelector pre-attached>

    super.attached();
    _logger.fine('TFNavContentSelector attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFNavContentSelector attached>
    _netWorthButton = $['net-worth-button']
      //        ..innerHtml = _netWorthIconHtml
      ..onClick.listen((_) => _buttonClicked(NET_WORTH_CONTENT));
    _totalAssetsButton = $['total-assets-button']
      //        ..innerHtml = _totalAssetsIconHtml
      ..onClick.listen((_) => _buttonClicked(TOTAL_ASSETS_CONTENT));
    _totalLiabilitiesButton = $['total-liabilities-button']
      //        ..innerHtml = _totalLiabilitiesIconHtml
      ..onClick.listen((_) => _buttonClicked(TOTAL_LIABILITIES_CONTENT));

    _netIncomeButton = $['net-income-button']
      ..innerHtml = _netIncomeIconHtml
      ..onClick.listen((_) => _buttonClicked(NET_INCOME_CONTENT));
    _totalIncomeButton = $['total-income-button']
      ..innerHtml = _totalIncomeIconHtml
      ..onClick.listen((_) => _buttonClicked(TOTAL_INCOME_CONTENT));
    _totalExpenseButton = $['total-expense-button']
      ..innerHtml = _totalExpenseIconHtml
      ..onClick.listen((_) => _buttonClicked(TOTAL_EXPENSE_CONTENT));

    _buttonClicked(NET_WORTH_CONTENT);
    // end <TFNavContentSelector attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFNavContentSelector)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFNavContentSelector>

  get _netWorthIconHtml => '<i></i><span> NW</span>';
  get _totalAssetsIconHtml => '<i></i><span> TA</span>';
  get _totalLiabilitiesIconHtml => '<i></i><span> TL</span>';
  get _netIncomeIconHtml => '<i></i><span> NI</span>';
  get _totalIncomeIconHtml => '<i></i><span> TI</span>';
  get _totalExpenseIconHtml => '<i></i><span> TE</span>';

  _buttonClicked(NavContentType type) {
    navContentType = type;
    _setDisplay();
    deliverChanges();
  }

  _setDisplay() {
    final buttons = [ _netWorthButton, _totalAssetsButton, _totalLiabilitiesButton,
      _netIncomeButton, _totalIncomeButton, _totalExpenseButton ];
    // for(final indexValue in enumerate(buttons)) {
    //   final icon = indexValue.value.children.first;
    //   //      final span = indexValue.value.children.last;
    //   if(navContentType.value == indexValue.index) {
    //     icon.classes.remove('text-muted');
    //     //        span.classes.remove('text-muted');
    //     indexValue.value.blur();
    //   } else {
    //     icon.classes.add('text-muted');
    //     //        span.classes.add('text-muted');
    //   }
    // }
  }

  // end <class TFNavContentSelector>
  Element _netWorthButton;
  Element _totalAssetsButton;
  Element _totalLiabilitiesButton;
  Element _netIncomeButton;
  Element _totalIncomeButton;
  Element _totalExpenseButton;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <t_f_nav_content_selector>
// end <t_f_nav_content_selector>
