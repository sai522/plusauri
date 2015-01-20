library nested;
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("nested");

@CustomTag("plus-nested")
class Nested extends PolymerElement {
  @observable String year;

  Nested.created() : super.created() {
    _logger.fine('Nested created sr => $shadowRoot');
    // custom <Nested created>
    // end <Nested created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('Nested domReady with sr => $shadowRoot');
    // custom <Nested domReady>
    // end <Nested domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('Nested ready with sr => $shadowRoot');
    // custom <Nested ready>
    // end <Nested ready>

  }

  @override
  void attached() {
    // custom <Nested pre-attached>
    // end <Nested pre-attached>

    super.attached();
    _logger.fine('Nested attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <Nested attached>
    // end <Nested attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(Nested)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class Nested>
  // end <class Nested>
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <nested>
// end <nested>
