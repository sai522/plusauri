library num_with_units_input;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:basic_input/input_utils.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("numWithUnitsInput");

@CustomTag("plus-num-with-units-input")
class NumWithUnitsInput extends CheckedInputField {

  String units;
  num get number => _number;

  NumWithUnitsInput.created() : super.created() {
    _logger.fine('NumWithUnitsInput created sr => $shadowRoot');
    // custom <NumWithUnitsInput created>
    // end <NumWithUnitsInput created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('NumWithUnitsInput domReady with sr => $shadowRoot');
    // custom <NumWithUnitsInput domReady>
    // end <NumWithUnitsInput domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('NumWithUnitsInput ready with sr => $shadowRoot');
    // custom <NumWithUnitsInput ready>
    // end <NumWithUnitsInput ready>

  }

  @override
  void attached() {
    // custom <NumWithUnitsInput pre-attached>
    input = $['num-with-units-input'];

    // end <NumWithUnitsInput pre-attached>

    super.attached();
    _logger.fine('NumWithUnitsInput attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <NumWithUnitsInput attached>

    placeholder = attributes['placeholder'];
    units = attributes['units'];

    // end <NumWithUnitsInput attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(NumWithUnitsInput)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }


  // custom <class NumWithUnitsInput>

  _formatNumber(num n) => (_formatter != null?
      _formatter.format(n) :
      numberFormat(n)) + (units != null? ' $units' : '');


  String _formatInput() => inputText = _formatNumber(_number);
  set number(num n) {
    _number = n;
    _formatInput();
  }

  @override
  String validateOnInput() {
    final txt = inputText;
    _number = pullNum(txt);
    if(_number == null) {
      return (inputText.length > 0)?
        "Please enter a valid number" :
        "This field is required";
    } else {
      _formatInput();
      return null;
    }
  }

  @override String validateOnBlur() => error;


  // end <class NumWithUnitsInput>
  InputElement _valueElement;
  NumberFormat _formatter;
  num _number;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <num_with_units_input>
// end <num_with_units_input>
