library menu_selector;
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:paper_elements/paper_menu_button.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("menuSelector");

@CustomTag("plus-menu-selector")
class MenuSelector extends PolymerElement {

  @observable String selection;
  List<Object> options = toObservable([]);

  MenuSelector.created() : super.created() {
    _logger.fine('MenuSelector created sr => $shadowRoot');
    // custom <MenuSelector created>
    // end <MenuSelector created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('MenuSelector domReady with sr => $shadowRoot');
    // custom <MenuSelector domReady>
    // end <MenuSelector domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('MenuSelector ready with sr => $shadowRoot');
    // custom <MenuSelector ready>
    // end <MenuSelector ready>

  }

  @override
  void attached() {
    // custom <MenuSelector pre-attached>
    // end <MenuSelector pre-attached>

    super.attached();
    _logger.fine('MenuSelector attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <MenuSelector attached>
    // end <MenuSelector attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(MenuSelector)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }


  // custom <class MenuSelector>

  setOptions(Iterable<Object> opts) {
    options.clear();
    opts.forEach((opt) => options.add(opt.toString()));
  }

  void onSelection(event, detail, target) {
    final sel = target.attributes['selection'];
    selection = sel;
  }

  // end <class MenuSelector>
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <menu_selector>
// end <menu_selector>
