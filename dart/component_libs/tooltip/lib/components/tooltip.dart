library tooltip;
import 'dart:async';
import 'dart:html' hide Timeline;
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

// custom <additional imports>
// end <additional imports>


final _logger = new Logger("tooltip");

@CustomTag("plus-tooltip")
class Tooltip extends PolymerElement {
  HtmlElement get container => _container;
  HtmlElement get closer => _closer;
  StreamSubscription<MouseEvent> get mouseLeaveBodySubscription => _mouseLeaveBodySubscription;
  StreamSubscription<MouseEvent> get mouseMoveSubscription => _mouseMoveSubscription;
  StreamSubscription<MouseEvent> get mouseUpSubscription => _mouseUpSubscription;

  Tooltip.created() : super.created() {
    _logger.fine('Tooltip created sr => $shadowRoot');
    // custom <Tooltip created>

    if (shadowRoot != null) {
      _container = $['container']..attributes['draggable'] = 'true';
      _closer = $['header-content'].querySelector('.closer')
      ..onClick.listen(_onClose);

      _initializeContent();
      _initializeDragSubscriptions();

      _container
          ..onDragStart.listen((MouseEvent me) {
            final bbrect = _container.getBoundingClientRect();
            Point positionInView = new Point(bbrect.left, bbrect.top);
            final mouseInView = me.client;
            final mouseInPage = _location(me);
            final offscreen = mouseInPage - mouseInView;
            final current = positionInView + offscreen;
            _mouseToTopOffset = mouseInPage - current;
            _resumeDragListeners();
            me.preventDefault();
          });

      //////////////////////////////////////////////////////////////////////
      // This cleanup effort will be fine in Dart but causes issues with
      // javascript.
      //$['hidden'].remove();
      hide();
    }

    // end <Tooltip created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('Tooltip domReady with sr => $shadowRoot');
    // custom <Tooltip domReady>
    // end <Tooltip domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('Tooltip ready with sr => $shadowRoot');
    // custom <Tooltip ready>
    // end <Tooltip ready>

  }

  @override
  void attached() {
    // custom <Tooltip pre-attached>
    // end <Tooltip pre-attached>

    super.attached();
    _logger.fine('Tooltip attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <Tooltip attached>
    // end <Tooltip attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(Tooltip)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class Tooltip>

  addTipContainerClass(String cls) => _container.classes.add(cls);
  addTipContentClass(String cls) => $['tip-content'].classes.add(cls);
  addHeaderClass(String cls) => $['header'].classes.add(cls);
  addFooterClass(String cls) => $['footer'].classes.add(cls);

  set tipChildrenHtml(List<String> htmls) => tipChildren = htmls.map((html) =>
      new Element.html(html));

  set tipChildren(Iterable<Element> elms) => $['tip-content'].children
      ..clear()
      ..addAll(elms);

  set headerContentElement(Element elm) => $['header-content'].children
      ..clear()
      ..add(elm..children.add(_closer));

  set footerContentElement(Element elm) => $['footer-content'].children
      ..clear()
      ..add(elm);

  show([MouseEvent me, Point offset]) {
    if (me != null) {
      _moveTo(_location(me, offset));
    } else if(offset != null) {
      _moveTo(offset);
    }
    _container.style.setProperty('display', 'block');
  }

  hide() => _container.style.setProperty('display', 'none');
  shown() => _container.style.display != 'none';

  _onClose(MouseEvent me) => remove();
  _onDragEnd(MouseEvent me) => _pauseDragListeners();

  _pauseDragListeners() {
    _mouseLeaveBodySubscription.pause();
    _mouseUpSubscription.pause();
    _mouseMoveSubscription.pause();
  }

  _resumeDragListeners() {
    _mouseLeaveBodySubscription.resume();
    _mouseUpSubscription.resume();
    _mouseMoveSubscription.resume();
  }

  _onDragging(MouseEvent me) => _moveTo(_location(me) - _mouseToTopOffset);

  _initializeContent() {
    final displayedContent = [];
    ($['hidden'].querySelector('content') as
        ContentElement).getDistributedNodes().where((Node node) => node is Element
        ).forEach((element) {
      if (element.tagName == 'HEADER') {
        headerContentElement = element;
      } else {
        if (element.tagName == 'FOOTER') {
          footerContentElement = element;
        } else {
          displayedContent.add(element);
        }
      }
    });

    tipChildren = displayedContent;
  }

  _initializeDragSubscriptions() {
    _mouseLeaveBodySubscription = document.body.onMouseLeave.listen(_onDragEnd);
    _mouseUpSubscription = document.body.onMouseUp.listen(_onDragEnd);
    _mouseMoveSubscription = document.body.onMouseMove.listen(_onDragging);
    _pauseDragListeners();
  }

  static _location(MouseEvent me, [Point offset]) => offset == null ? new Point(
      me.page.x, me.page.y) : new Point(me.page.x + offset.x, me.page.y + offset.y);

  _moveTo(Point location) => _container.style
      ..setProperty('top', '${location.y}px')
      ..setProperty('left', '${location.x}px');

  // end <class Tooltip>
  HtmlElement _container;
  HtmlElement _closer;
  Point _mouseToTopOffset;
  StreamSubscription<MouseEvent> _mouseLeaveBodySubscription;
  StreamSubscription<MouseEvent> _mouseMoveSubscription;
  StreamSubscription<MouseEvent> _mouseUpSubscription;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <tooltip>
// end <tooltip>
