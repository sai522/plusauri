library basic_input.input_utils;

import 'package:observe/observe.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';
// custom <additional imports>
import 'dart:html';
// end <additional imports>

/// Wraps a PaperInput with consistent API supporting required
abstract class CheckedInputField extends PolymerElement {

  /// Label/placeholder text
  @observable String placeholder = 'Enter amount';
  /// If true this is a requried field
  @observable bool required = true;
  @observable String error;

  // custom <class CheckedInputField>

  CheckedInputField.created() : super.created();

  void setError(String text) {
    error = text;
    _input.jsElement.callMethod('setCustomValidity', [error]);
  }

  bool get isValid =>
    error == null &&
    _input.inputValue != null &&
    (!required || _input.inputValue.length > 0);

  String get inputText => _input.inputValue;

  set inputText(String text) =>
    _input.inputValue = text;

  set input(PaperInput paperInput) => _input = paperInput;

  clear() => clearPaperInput(_input);

  @override
  void attached() {
    super.attached();
    _input.onInput.listen((var _) {
      setError(validateOnInput());
    });
    _input.onBlur.listen((var _) {
      setError(validateOnBlur());
    });
  }

  String validateOnInput();
  String validateOnBlur();
  bool get hasContent {
    final txt = inputText;
    return txt != null && txt.length > 0;
  }

  onUpdate(observer) =>
    _input.onInput.listen((Event event) {
      observer(event);
    });

  // end <class CheckedInputField>
  PaperInput _input;
}

// custom <library input_utils>

clearPaperInput(PaperInput paperInput) =>
  (paperInput
      ..jsElement.callMethod('setCustomValidity', [])
      ..inputValue = '')
      .querySelector('* /deep/ #input')
  ..focus()
  ..blur();

// end <library input_utils>
