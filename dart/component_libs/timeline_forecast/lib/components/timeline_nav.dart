library timeline_nav;
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/timeline_model.dart';
import 'timeline.dart';
import 'timeline_header.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("timelineNav");

@CustomTag("plus-timeline-nav")
/// Primary navigation container for the timeline.
///
/// It models the timeline for one or more Timeline models (each which just wraps a
/// MultiYearForecast and pulls out some data) instances (It contains one or more
/// TimelineView instances, each focused on one or more models.
///
///
class TimelineNav extends PolymerElement {

  TimelineNav.created() : super.created() {
    _logger.fine('TimelineNav created sr => $shadowRoot');
    // custom <TimelineNav created>
    // end <TimelineNav created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TimelineNav domReady with sr => $shadowRoot');
    // custom <TimelineNav domReady>
    // end <TimelineNav domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TimelineNav ready with sr => $shadowRoot');
    // custom <TimelineNav ready>
    // end <TimelineNav ready>

  }

  @override
  void attached() {
    // custom <TimelineNav pre-attached>
    // end <TimelineNav pre-attached>

    super.attached();
    _logger.fine('TimelineNav attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TimelineNav attached>
    
    _timelineHeader = $['timeline-header'];
    _timelineComponent = $['timeline-component'];
    _shellDiv = $['shell'];

    _timelineHeader.onAnnualComponentsChange(
      (toggleSet) => _timelineComponent.annualComponentsDisplayed = toggleSet);

    _timelineHeader.onNavComponentChange(
      (navContentType) => _timelineComponent.showContent(navContentType));
    
    // end <TimelineNav attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TimelineNav)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TimelineNav>

  onAnnualComponentsChange(AnnualComponentsChangeObserver observer) =>
    _timelineHeader.onAnnualComponentsChange(observer);

  set comparisonModel(TimelineComparisonModel model) {
    _comparisonModel = model;
    _timelineComponent.comparisonModel = model;
  }
  // end <class TimelineNav>
  DivElement _shellDiv;
  TimelineHeader _timelineHeader;
  Timeline _timelineComponent;
  TimelineComparisonModel _comparisonModel;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <timeline_nav>
// end <timeline_nav>
