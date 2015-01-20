library simple_string_input;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:basic_input/input_utils.dart';
import 'package:logging/logging.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("simpleStringInput");

@CustomTag("plus-simple-string-input")
class SimpleStringInput extends CheckedInputField {

  StringValueConstraint valueConstraint;

  SimpleStringInput.created() : super.created() {
    _logger.fine('SimpleStringInput created sr => $shadowRoot');
    // custom <SimpleStringInput created>
    // end <SimpleStringInput created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('SimpleStringInput domReady with sr => $shadowRoot');
    // custom <SimpleStringInput domReady>
    // end <SimpleStringInput domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('SimpleStringInput ready with sr => $shadowRoot');
    // custom <SimpleStringInput ready>
    // end <SimpleStringInput ready>

  }

  @override
  void attached() {
    // custom <SimpleStringInput pre-attached>
    input = $['simple-string'] as PaperInput;
    // end <SimpleStringInput pre-attached>

    super.attached();
    _logger.fine('SimpleStringInput attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <SimpleStringInput attached>

    placeholder = attributes['placeholder'];

    // end <SimpleStringInput attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(SimpleStringInput)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }


  // custom <class SimpleStringInput>

  @override String validateOnInput() =>
    valueConstraint != null?
    valueConstraint(inputText) : error;

  @override String validateOnBlur() => error;

  // end <class SimpleStringInput>
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <simple_string_input>
// end <simple_string_input>
