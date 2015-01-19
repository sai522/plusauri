library timeline_header;
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/timeline_enums.dart';
import 't_f_annual_component_toggler.dart';
import 't_f_nav_content_selector.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("timelineHeader");

@CustomTag("plus-timeline-header")
/// Displays the current active display type (Net Worth, Total Assets, ... ), allowing users to switch between
class TimelineHeader extends PolymerElement {

  TimelineHeader.created() : super.created() {
    _logger.fine('TimelineHeader created sr => $shadowRoot');
    // custom <TimelineHeader created>
    // end <TimelineHeader created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TimelineHeader domReady with sr => $shadowRoot');
    // custom <TimelineHeader domReady>
    // end <TimelineHeader domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TimelineHeader ready with sr => $shadowRoot');
    // custom <TimelineHeader ready>
    // end <TimelineHeader ready>

  }

  @override
  void attached() {
    // custom <TimelineHeader pre-attached>
    // end <TimelineHeader pre-attached>

    super.attached();
    _logger.fine('TimelineHeader attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TimelineHeader attached>
    
    _annualComponentToggler = $['annual-component-toggler'];
    _navContentSelector = $['nav-content-selector'];
    
    // end <TimelineHeader attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TimelineHeader)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TimelineHeader>

  onAnnualComponentsChange(AnnualComponentsChangeObserver observer) =>
    _annualComponentToggler.changes.listen((records) {
          if(records.any((record) => record.name == #toggledOnSet)) {
            observer(_annualComponentToggler.toggledOnSet);
          }
        });

  onNavComponentChange(NavComponentChangeObserver observer) =>
    _navContentSelector.changes.listen((records) {
          if(records.any((record) => record.name == #navContentType)) {
            observer(_navContentSelector.navContentType);
          }
        });

  // end <class TimelineHeader>
  TFAnnualComponentToggler _annualComponentToggler;
  TFNavContentSelector _navContentSelector;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <timeline_header>

typedef void
  AnnualComponentsChangeObserver(Set<AnnualComponentType> selectedComponents);

typedef void
  NavComponentChangeObserver(NavContentType navContentType);

// end <timeline_header>
