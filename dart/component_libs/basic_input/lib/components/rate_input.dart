library rate_input;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:basic_input/input_utils.dart';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>

// end <additional imports>


final _logger = new Logger("rateInput");

@CustomTag("plus-rate-input")
class RateInput extends CheckedInputField {

  num get rate => _rate;

  RateInput.created() : super.created() {
    _logger.fine('RateInput created sr => $shadowRoot');
    // custom <RateInput created>
    // end <RateInput created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('RateInput domReady with sr => $shadowRoot');
    // custom <RateInput domReady>
    // end <RateInput domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('RateInput ready with sr => $shadowRoot');
    // custom <RateInput ready>
    // end <RateInput ready>

  }

  @override
  void attached() {
    // custom <RateInput pre-attached>
    input = $['rate-input'];
    // end <RateInput pre-attached>

    super.attached();
    _logger.fine('RateInput attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <RateInput attached>

    placeholder = attributes['placeholder'];

    // end <RateInput attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(RateInput)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }


  // custom <class RateInput>

  double get rateAsPct => pullNum(inputText, 0)/100.0;
  String _formatInput() => inputText = percentFormat(_rate, true);
  set rate(num r) {
    _rate = r;
    _formatInput();
  }


  @override String validateOnInput() => null;

  @override String validateOnBlur() {
    const errorMsg = "Please enter valid percent (e.g. 20%)";
    try {
      final r = pullNum(inputText);
      if(r == null) return errorMsg;
      rate = r/100.0;
      return null;
    } on Exception catch(e) {
      return errorMsg;
    }
  }

  // end <class RateInput>
  num _rate = 0;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <rate_input>
// end <rate_input>
