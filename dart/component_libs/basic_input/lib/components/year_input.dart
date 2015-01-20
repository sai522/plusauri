library year_input;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("yearInput");

@CustomTag("plus-year-input")
class YearInput extends PolymerElement {

  int get year => _year;

  YearInput.created() : super.created() {
    _logger.fine('YearInput created sr => $shadowRoot');
    // custom <YearInput created>
    // end <YearInput created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('YearInput domReady with sr => $shadowRoot');
    // custom <YearInput domReady>
    // end <YearInput domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('YearInput ready with sr => $shadowRoot');
    // custom <YearInput ready>
    // end <YearInput ready>

  }

  @override
  void attached() {
    // custom <YearInput pre-attached>
    // end <YearInput pre-attached>

    super.attached();
    _logger.fine('YearInput attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <YearInput attached>
    // end <YearInput attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(YearInput)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }


  // custom <class YearInput>
  // end <class YearInput>
  InputElement _yearElement;
  int _year;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <year_input>
// end <year_input>
