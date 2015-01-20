library date_input;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:basic_input/input_utils.dart';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("dateInput");

@CustomTag("plus-date-input")
class DateInput extends CheckedInputField {

  DateTime get date => _date;

  DateInput.created() : super.created() {
    _logger.fine('DateInput created sr => $shadowRoot');
    // custom <DateInput created>
    // end <DateInput created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('DateInput domReady with sr => $shadowRoot');
    // custom <DateInput domReady>
    // end <DateInput domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('DateInput ready with sr => $shadowRoot');
    // custom <DateInput ready>
    // end <DateInput ready>

  }

  @override
  void attached() {
    // custom <DateInput pre-attached>
    input = $['date-input'];
    // end <DateInput pre-attached>

    super.attached();
    _logger.fine('DateInput attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <DateInput attached>

    placeholder = attributes['placeholder'];

    // end <DateInput attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(DateInput)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }


  // custom <class DateInput>

  String _formatInput() => inputText = dateFormat(_date);
  set date(DateTime d) {
    _date = d;
    _formatInput();
  }

  @override String validateOnInput() => null;
  @override String validateOnBlur() {
    final txt = inputText;
    if(txt.length == 0) return null;
    _date = pullDate(txt);
    if(_date == null) {
      return (inputText.length > 0)?
        "Please enter a valid date (YYYY-DD-MM)" :
        "This field is required";
    } else {
      _formatInput();
      return null;
    }
  }

  // end <class DateInput>
  DateTime _date;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <date_input>
// end <date_input>
