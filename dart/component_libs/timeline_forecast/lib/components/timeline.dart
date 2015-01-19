library timeline;
import 'dart:async';
import 'dart:html' hide Timeline;
import 'dart:math' show min, max, Point;
import 'dart:svg' as svg show Point;
import 'dart:svg' hide Point;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:polymer/polymer.dart';
import 'package:quiver/iterables.dart' hide min, max;
import 'package:timeline_forecast/current_dollars.dart';
import 'package:timeline_forecast/timeline_enums.dart';
import 'package:timeline_forecast/timeline_model.dart';
import 't_f_annual_forecast.dart';
import 't_f_balance_sheet.dart';
import 't_f_income_statement.dart';
import 't_f_liquidation_summary.dart';
import 't_f_tax_summary.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("timeline");

@CustomTag("plus-timeline")
class Timeline extends PolymerElement {
  Point get innerMargin => _innerMargin;
  double get displayWidth => _displayWidth;
  double get displayHeight => _displayHeight;
  double get yearLabelHeight => _yearLabelHeight;
  double get labelToLineMargin => _labelToLineMargin;

  Timeline.created() : super.created() {
    _logger.fine('Timeline created sr => $shadowRoot');
    // custom <Timeline created>
    // end <Timeline created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('Timeline domReady with sr => $shadowRoot');
    // custom <Timeline domReady>
    // end <Timeline domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('Timeline ready with sr => $shadowRoot');
    // custom <Timeline ready>
    // end <Timeline ready>

  }

  @override
  void attached() {
    // custom <Timeline pre-attached>
    // end <Timeline pre-attached>

    super.attached();
    _logger.fine('Timeline attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <Timeline attached>

    _originOffset = new Point(
      _origin.x + _innerMargin.x,
      _origin.y + _innerMargin.y + _yearLabelHeight + _labelToLineMargin);

    _svgContainer..id = 'svg-container';
    _shellDiv = $['shell']..nodes.add(_svgContainer);
    _annualForecastsContainer = $['annual-forecasts-container'];

    _point = _svgContainer.createSvgPoint();

    [ _topLine, _bottomLine ].forEach((line) {
      _styleHorizontalLine(line);
      _commonGroup.nodes.add(line);
    });

    _svgContainer
      ..nodes.addAll([ _highlightRect, _commonGroup, _yearElementsGroup, _visualsGroup ])
      ..onMouseMove.listen((e) => _trackMovement(e))
      ..onClick.listen((e) => _evaluateClick(e));

    window.onResize.listen((_) => _fitToWidth());
    new Timer(const Duration(milliseconds: 30), () {
      _fitToWidth();
      showContent(NET_WORTH_CONTENT);
    });

    // end <Timeline attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(Timeline)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class Timeline>

  _fitToWidth() {
    final newWidth = _shellDiv.clientWidth.floorToDouble();
    final newHeight = _shellDiv.clientHeight.floorToDouble();
    // First just changes height, second triggers redisplay
    _displayHeight = newHeight;
    displayWidth = newWidth;
  }

  set comparisonModel(TimelineComparisonModel model) {
    _comparisonModel = model;
    _dateRange = model.dateRange;
    _startYear = _dateRange.start.year;
    _numYears = _dateRange.end.year - _dateRange.start.year;
    _focusYear = _dateRange.end.year - 1;
    _clearContents();
    _createYearElements();
    _createModelVisuals();
    _createAnnualForecasts();
    _sizeDisplay();
  }

  set displayWidth(num width) {
    _displayWidth = width;
    _sizeDisplay();
  }

  set displayHeight(num height) {
    _displayHeight = height;
    _sizeDisplay();
  }

  set annualComponentsDisplayed(Set<AnnualComponentType> displayedComponents) {
    _annualForecastsContainer.children.forEach((TFAnnualForecast annualForecast) {
      annualForecast.setDisplayedComponents(displayedComponents);
    });
  }

  static const _contentTypeToDisplayType = const {
    NET_WORTH_CONTENT: NET_WORTH,
    TOTAL_ASSETS_CONTENT: TOTAL_ASSETS,
    TOTAL_LIABILITIES_CONTENT: TOTAL_LIABILITIES,

    NET_INCOME_CONTENT: NET_INCOME,
    TOTAL_INCOME_CONTENT: TOTAL_INCOME,
    TOTAL_EXPENSE_CONTENT: TOTAL_EXPENSE,
  };

  showContent(NavContentType navContentType) {
    _visualsByDisplayType.forEach((contentType, visualsForDisplayType) {
      final displayType = _contentTypeToDisplayType[navContentType];
      if(displayType != null) {
        if(contentType == displayType) {
          visualsForDisplayType.showVisuals();
        } else {
          visualsForDisplayType.hideVisuals();
        }
      }
    });
  }

  void _trackMovement(MouseEvent e) {
    _transformMouseLocation(e);
    final mouseY = _point.y;
    if(mouseY < _yPos(_innerHeight) && mouseY > _yPos(0)) {
      _setFocusYear(_yearFromX(_point.x));
    }
  }

  _setFocusYear(int year) {
    if(year != _focusYear) {
      _focusYear = max(_startYear, min(_startYear + _numYears - 1, year));
      _moveHighlightRect();
      int i=0;
      _comparisonModel.timelineModels.forEach((key, ITimelineModel timelineModel) {
        final TFAnnualForecast annualForecast = _annualForecastsContainer.children[i++];
        annualForecast.setModel(timelineModel.annualForecastModel(key, _focusYear));
      });
      _fitToWidth();
    }
  }

  _yearIndex(int year) => year - _startYear;

  _moveHighlightRect() {
    final index = _yearIndex(_focusYear);
    final x = _yearElements[index].x;
    _highlightRect.attributes
      ..['style'] = 'fill:#f7f7af;fill-opacity:0.2;stroke:#130e14;stroke-opacity:1'
      ..['x'] = '$x'
      ..['y'] = '${_y(0)}'
      ..['width'] = '$_yearWidth'
      ..['height'] = '$_innerHeight'
      ..['display'] = '';
  }

  void _evaluateClick(MouseEvent e) {
    _transformMouseLocation(e);
    print('Mouse clicked $e');
  }

  _yearIndexFromX(double x) =>
    (((x+0.0001-_xPos(0))/(_innerWidth)) * _numYears).floor();

  _yearFromX(double x) => _startYear + _yearIndexFromX(x);

  _clearContents() {
    _clearYearElements();
    _clearModelVisuals();
    _annualForecastsContainer.children.clear();
  }

  _clearModelVisuals() {}

  _clearYearElements() {
    _yearElements.clear();
    _yearElementsGroup.children.clear();
  }

  _createAnnualForecasts() {
    _comparisonModel.timelineModels.forEach((key, ITimelineModel timelineModel) =>
        _annualForecastsContainer.children.add(new Element.tag('plus-t-f-annual-forecast')));
    _setFocusYear(_comparisonModel.dateRange.start.year);
  }

  _createModelVisuals() {

    final visualCreators = {
      NET_WORTH : (dbl) => new NetWorthVisual(dbl),
      TOTAL_ASSETS : (dbl) => new TotalAssetVisual(dbl),
      TOTAL_LIABILITIES: (dbl) => new TotalLiabilityVisual(dbl),

      NET_INCOME : (dbl) => new NetIncomeVisual(dbl),
      TOTAL_INCOME : (dbl) => new TotalIncomeVisual(dbl),
      TOTAL_EXPENSE : (dbl) => new TotalExpenseVisual(dbl),
    };

    const balanceTypes = const {
      NET_WORTH : NET_WORTH_BALANCE,
      TOTAL_ASSETS : TOTAL_ASSETS_BALANCE,
      TOTAL_LIABILITIES : TOTAL_LIABILITIES_BALANCE
    };

    const flowTypes = const {
      NET_INCOME : NET_INCOME_FLOW,
      TOTAL_INCOME : TOTAL_INCOME_FLOW,
      TOTAL_EXPENSE : TOTAL_EXPENSE_FLOW
    };

    for(final displayType in DisplayType.values) {
      final visuals = new VisualsForDisplayType(displayType, _startYear, _numYears);
      _visualsByDisplayType[displayType] = visuals;
      _visualsGroup.nodes.add(visuals.group);
    }

    _comparisonModel.timelineModels.forEach((key, ITimelineModel timelineModel) {
      visualCreators.keys.where((k) => balanceTypes.containsKey(k)).forEach((displayType) {
        final forecastBalances = balancesByType(timelineModel, balanceTypes[displayType]);
        final visualsForDisplayType = _visualsByDisplayType[displayType];

        visualsForDisplayType.minValue = min(visualsForDisplayType.minValue,
            forecastBalances.minBalance);
        visualsForDisplayType.maxValue = max(visualsForDisplayType.maxValue,
            forecastBalances.maxBalance);

        final visualFactory = visualCreators[displayType];

        assert(forecastBalances.length == _numYears);
        forecastBalances.periodBalances.forEach((pb) {
          final value = pb.end.value;
          if(displayType == NET_WORTH || value != 0) {
            final newVisual = visualFactory(value);
            visualsForDisplayType.setVisual(key, pb.end.date.year - 1, newVisual);
          }
        });
      });

      visualCreators.keys.where((k) => flowTypes.containsKey(k)).forEach((displayType) {
        final forecastFlows = flowsByType(timelineModel, flowTypes[displayType]);
        final visualsForDisplayType = _visualsByDisplayType[displayType];

        visualsForDisplayType.minValue = min(visualsForDisplayType.minValue,
            forecastFlows.minFlow);
        visualsForDisplayType.maxValue = max(visualsForDisplayType.maxValue,
            forecastFlows.maxFlow);

        final visualFactory = visualCreators[displayType];
        assert(forecastFlows.flowsByYear.length == _numYears);
        forecastFlows.flowsByYear.forEach((yearIncomeFlows) {
          final value = yearIncomeFlows.netFlow;
          if(displayType == NET_INCOME || value != 0) {
            final newVisual = visualFactory(value);
            visualsForDisplayType.setVisual(key, yearIncomeFlows.year, newVisual);
          }
        });
      });
    });
  }

  _createYearElements() {
    yearElements(int year) {
      final result = new _YearElements(year);
      _yearElementsGroup.nodes.addAll([result.verticalLine,
        result.yearTopLabel, result.yearBottomLabel]);
      return result;
    }

    _yearElements = new List.generate
      (_numYears, (i) => yearElements(_startYear + i), growable:true);
    _yearElements.add(yearElements(_startYear + _numYears));
  }

  _sizeAndPositionYearElements() {
    final yTop = _yPos(0);
    final yBottom = _yPos(_innerHeight);

    for(final indexValue in enumerate(_yearElements)) {
      final x = _xPos(indexValue.index * _yearWidth);
      indexValue.value.sizeAndPosition(x, yTop, yBottom, _labelToLineMargin);
    }

    _visualsByDisplayType.forEach(
        (DisplayType displayType,
            VisualsForDisplayType visualsForDisplayType) {

      double minValue = visualsForDisplayType.minValue;
      double maxValue = visualsForDisplayType.maxValue;

      // TODO: remove/fix
      if(minValue == null || maxValue == null) return;

      minValue = roundToFloor(minValue, 3).toDouble();
      maxValue = roundToCeil(maxValue, 3).toDouble();

      double spread = maxValue - minValue;
      if(!spread.isFinite) return;

      _positionElement(visualsForDisplayType.minLabel, _xPos(-10), _yPos(_innerHeight));
      _positionElement(visualsForDisplayType.maxLabel, _xPos(-10), _yPos(0));

      final middleYPos = _yPos(_innerHeight/2.0);
      final innerMargin = 4.0;
      final heightBasis = _innerHeight - 2*innerMargin;

      for(final indexValue in enumerate(visualsForDisplayType.visualsByYear)) {
        final index = indexValue.index;
        final visualsInYear = indexValue.value;
        visualsInYear.visuals.forEach((key, visual) {
          assert(visual.value <= maxValue);
          assert(visual.value >= minValue);

          final x = _yearElements[index].x + _yearWidth/2;
          double y = middleYPos;
          if(spread != 0.0) {
            final pctHeight = (visual.value - minValue)/spread;
            //y = _yPos(_innerHeight - pctHeight * _innerHeight);
            y = _yPos(_innerHeight - innerMargin - pctHeight * heightBasis);
          }
          visual.moveTo(x, y);
        });
      }

      visualsForDisplayType.setMinLabel(minValue);
      visualsForDisplayType.setMaxLabel(maxValue);

    });
  }

  _sizeCommonGroupItems() {
    final width = _innerWidth;
    final height = _innerHeight;
    _sizeLine(_topLine, 0, width, 0, 0);
    _sizeLine(_bottomLine, 0, width, height, height);
  }

  get _innerWidth => _displayWidth - 2*_innerMargin.x;
  get _innerHeight => _displayHeight - 2*(_innerMargin.y + _yearLabelHeight) -
    _labelToLineMargin;

  _sizeLine(line, num x1, num x2, num y1, num y2) =>
    line.attributes
    ..['x1'] = _x(x1)..['x2'] = _x(x2) ..['y1'] = _y(y1)..['y2'] = _y(y2);

  _xPos(num x) => _originOffset.x + x;
  _yPos(num y) => _originOffset.y + y;

  _x(num x) => '${_xPos(x)}';
  _y(num y) => '${_yPos(y)}';

  _styleHorizontalLine(line) =>
    line.attributes['style'] =
    'stroke:rgb(0,0,0);stroke-width:2;stroke-opacity:0.4';

  _sizeDisplay() {
    if(_yearElements.length == 0) return;
    _yearWidth = _innerWidth / _numYears;
    _sizeCommonGroupItems();
    _sizeAndPositionYearElements();
    final totalLabelSizes = _yearElements[0].yearTopLabel.getBBox().width * _numYears;
    bool showEveryFive = (totalLabelSizes/_displayWidth) > 0.60;
    _yearElements
      .where((ye) => (ye.year % 5) != 0)
      .forEach((ye) => showEveryFive? ye.hideLabels() : ye.showLabels());
    _moveHighlightRect();
    _svgContainer.style.setProperty('width', '${_displayWidth}px');
    _svgContainer.style.setProperty('height', '${_displayHeight}px');
  }

  _transformMouseLocation(MouseEvent event) {
    _point.x = event.client.x;
    _point.y = event.client.y;
    _point = _point.matrixTransform(_svgContainer.getScreenCtm().inverse());
  }

  // end <class Timeline>
  TimelineComparisonModel _comparisonModel;
  /// Range of the forecasts - it is assumed all forecasts are on the same range
  DateRange _dateRange;
  SvgSvgElement _svgContainer = new SvgSvgElement();
  DivElement _annualForecastsContainer;
  DivElement _shellDiv;
  RectElement _highlightRect = new RectElement();
  svg.Point _point;
  /// Starting offset for the axis within svg
  Point _origin = new Point(0.0,0.0);
  Point _originOffset = new Point(0.0,0.0);
  Point _innerMargin = new Point(55.0,15.0);
  double _displayWidth = 650.0;
  double _displayHeight = 150.0;
  double _yearLabelHeight = 14.0;
  double _labelToLineMargin = 4.0;
  int _numYears = 0;
  int _startYear = 0;
  /// Year in the timeline which is the current focus
  int _focusYear = 0;
  double _yearWidth = 0.0;
  /// Group containing all elements that do not change when swapping display (eg topLine, bottomLine, year labels,...)
  GElement _commonGroup = new GElement();
  /// Model dependent group containing elements that vary by year
  GElement _yearElementsGroup = new GElement();
  GElement _visualsGroup = new GElement();
  LineElement _topLine = new LineElement();
  LineElement _bottomLine = new LineElement();
  List<_YearElements> _yearElements = [];
  Map<DisplayType, VisualsForDisplayType> _visualsByDisplayType = {};
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}


/// Packages the visual element and the value it represents
class Visual {
  Visual(this.value, this.element);

  double value = 0.0;
  Element element;
  // custom <class Visual>

  moveTo(double x, double y) =>
    element.attributes
      ..['cx'] = '$x'
      ..['cy'] = '$y';

  // end <class Visual>
}

class NetWorthVisual extends Visual {
  // custom <class NetWorthVisual>

  NetWorthVisual(double value) : super(value, _elmFactory()) {
    if(value > 0) {
      element.style.setProperty('fill', 'gold');
    } else {
      element.style.setProperty('fill', 'red');
    }
  }

  static _elmFactory() => _netWorthVisual();
  moveTo(double x, double y) => _netWorthMoveTo(element, x, y);

  // end <class NetWorthVisual>
}

class TotalAssetVisual extends Visual {
  // custom <class TotalAssetVisual>

  TotalAssetVisual(double value) : super(value, _elmFactory());

  moveTo(double x, double y) => _assetMoveTo(element, x, y);

  static _elmFactory() => _assetVisual();

  // end <class TotalAssetVisual>
}

class TotalLiabilityVisual extends Visual {
  // custom <class TotalLiabilityVisual>

  TotalLiabilityVisual(double value) : super(value, _elmFactory());

  moveTo(double x, double y) =>
    _liabilityMoveTo(element, x, y);

  static _elmFactory() => _liabilityVisual();

  // end <class TotalLiabilityVisual>
}

class NetIncomeVisual extends Visual {
  // custom <class NetIncomeVisual>

  NetIncomeVisual(double value) : super(value,
      value < 0? _expenseVisual() : _incomeVisual());

  static _elmFactory() => _defaultPointVisual();

  moveTo(double x, double y) =>
    value < 0? _expenseMoveTo(element, x, y) :
    _incomeMoveTo(element, x, y);


  // end <class NetIncomeVisual>
}

class TotalIncomeVisual extends Visual {
  // custom <class TotalIncomeVisual>

  TotalIncomeVisual(double value) : super(value, _elmFactory());

  static _elmFactory() { return  _incomeVisual(); }

  moveTo(double x, double y) => _incomeMoveTo(element, x, y);

  // end <class TotalIncomeVisual>
}

class TotalExpenseVisual extends Visual {
  // custom <class TotalExpenseVisual>

  TotalExpenseVisual(double value) : super(value, _elmFactory());

  static _elmFactory() => _expenseVisual();
  moveTo(double x, double y) => _expenseMoveTo(element, x, y);

  // end <class TotalExpenseVisual>
}

/// The visuals within a year
class VisualsInYear {
  VisualsInYear(this.year);

  int year = 0;
  Map<String, Visual> visuals = {};
  // custom <class VisualsInYear>
  // end <class VisualsInYear>
}

/// Manages all visuals of a single display type
class VisualsForDisplayType {
  VisualsForDisplayType(this.displayType, this.startYear, this.numYears) {
    // custom <VisualsForDisplayType>

    visualsByYear = new List.generate(numYears,
        (i) => new VisualsInYear(startYear + i), growable:false);

    minLabel.attributes
      ..['text-anchor'] = 'end'
      ..['font-size'] = '$_legendLabelFontSize';

    maxLabel.attributes
      ..['text-anchor'] = 'end'
      ..['dominant-baseline'] = 'hanging'
      ..['font-size'] = '$_legendLabelFontSize';

    group.nodes.addAll([minLabel, maxLabel]);

    // end <VisualsForDisplayType>
  }

  DisplayType displayType;
  int startYear = 0;
  int numYears = 0;
  TextElement minLabel = new TextElement();
  TextElement maxLabel = new TextElement();
  double minValue = double.MAX_FINITE;
  double maxValue = -double.MAX_FINITE;
  GElement group = new GElement();
  List<VisualsInYear> visualsByYear;
  double get legendLabelFontSize => _legendLabelFontSize;
  // custom <class VisualsForDisplayType>

  setMinLabel(double labelMin) =>
    minLabel..innerHtml = '${moneyShortForm(roundToFloor(labelMin, 3).toDouble())}';

  setMaxLabel(double labelMax) =>
    maxLabel..innerHtml = '${moneyShortForm(roundToCeil(labelMax, 3).toDouble())}';

  _yearIndex(int year) => year - startYear;

  setVisual(String key, int year, Visual visual) {
    visualsByYear[_yearIndex(year)].visuals[key] = visual;
    group.nodes.add(visual.element);
  }

  hideVisuals() => group.attributes['display'] = 'none';
  showVisuals() => group.attributes.remove('display');

  // end <class VisualsForDisplayType>
  static double _legendLabelFontSize = 10.0;
}

class _YearElements {
  _YearElements(this.year) {
    // custom <_YearElements>

    final text = _yearText(year);
    (yearTopLabel..innerHtml = text).attributes
      ..['x'] = '$x'
      ..['font-size'] = '$_yearLabelFontSize'
      ..['text-anchor'] = 'middle';

    (yearBottomLabel..innerHtml = text).attributes
      ..['x'] = '$x'
      ..['font-size'] = '$_yearLabelFontSize'
      ..['text-anchor'] = 'middle'
      ..['dominant-baseline'] = 'hanging';

    verticalLine
      ..attributes['style'] =
      'stroke-dasharray: 4 2; stroke:rgb(0,0,0);stroke-width:1;stroke-opacity:0.4';

    // end <_YearElements>
  }

  int year = 0;
  double x = 0.0;
  LineElement verticalLine = new LineElement();
  TextElement yearTopLabel = new TextElement();
  TextElement yearBottomLabel = new TextElement();
  double get yearLabelFontSize => _yearLabelFontSize;
  // custom <class YearElements>

  static _yearText(int year) => "'${(((year*100)%10000)/100).round()}";

  hideLabels() {
    yearTopLabel.attributes['display'] = 'none';
    yearBottomLabel.attributes['display'] = 'none';
  }

  showLabels() {
    yearTopLabel.attributes.remove('display');
    yearBottomLabel.attributes.remove('display');
  }

  sizeAndPosition(double xPos, double yTop, double yBottom, double lineToLabelMargin) {
    x = xPos;
    final xPosStr = '$xPos';
    final yTopStr = '$yTop';
    final yBottomStr = '$yBottom';

    yearTopLabel.attributes
      ..['x'] = xPosStr
      ..['y'] = '${yTop - lineToLabelMargin}';

    yearBottomLabel.attributes
      ..['x'] = xPosStr
      ..['y'] = '${yBottom + lineToLabelMargin}';

    verticalLine.attributes
      ..['x1'] = xPosStr
      ..['x2'] = xPosStr
      ..['y1'] = yTopStr
      ..['y2'] = yBottomStr;
  }

  // end <class YearElements>
  static double _yearLabelFontSize = 14.0;
}


// custom <timeline>

_assetVisual() => new SvgElement.svg('''
    <circle cx="10" cy="10" r="3" style="stroke: navy; fill: gold;"/>
''');

_assetMoveTo(Element elm, double x, double y) =>
  elm
  ..attributes['cx'] = '$x'
  ..attributes['cy'] = '$y';

_liabilityVisual() => new SvgElement.svg('''
    <circle cx="10" cy="10" r="3" style="stroke: navy; fill: red;"/>
''');

_liabilityMoveTo(Element elm, double x, double y) =>
  elm
  ..attributes['cx'] = '$x'
  ..attributes['cy'] = '$y';
/*
_netWorthVisual() => new SvgElement.svg('''
    <circle cx="10" cy="10" r="3" style="stroke: navy; fill: gold;"/>
''');

_netWorthMoveTo(Element elm, double x, double y) =>
  elm
  ..attributes['cx'] = '$x'
  ..attributes['cy'] = '$y';
*/

_netWorthVisual() => new SvgElement.svg('''
    <rect width="5" height="5" style="stroke: navy; fill: gold;"/>
''');

_netWorthMoveTo(Element elm, double x, double y) =>
  elm
  ..attributes['transform'] =  "translate(${x}, ${y-2.5})rotate(45)";
//  ..attributes['x'] = '${x-2.5}'
//  ..attributes['y'] = '${y-2.5}';

_incomeVisual() => new SvgElement.svg('''
<path d="M 15 0 L 12 6 L 18 6 Z " style="fill:green;"/>
''');

_incomeMoveTo(Element elm, double x, double y) =>
  elm.attributes['transform'] = 'translate(${x-15},${y-3})';

_expenseVisual() => new SvgElement.svg('''
<path d="M 0 0 L 8 0 L 4 4 Z " style="fill:red;"  />
''');

_expenseMoveTo(Element elm, double x, double y) =>
  elm.attributes['transform'] = 'translate(${x-2},${y-2})';

_xMarkVisual() => new SvgElement.svg('''
<path d="M 15 0 L 20 5 M 20 0 L 15 5 " style="stroke: black; stroke-width: 1.5; fill:none;" />
''');

_xMarkMoveTo(Element elm, double x, double y) =>
  elm.attributes['transform'] = 'translate(${x-17.5},${y-10})';

_plusVisual() => new SvgElement.svg('''
<path d="M 15 0 L 20 5 M 20 0 L 15 5 "/>
''');

_plusMoveTo(Element elm, double x, double y) =>
  elm.attributes['transform'] = 'translate(${x-17.5},${y-10})';

_defaultPointVisual() => new SvgElement.svg('''
    <circle cx="10" cy="10" r="3" style="stroke: navy; fill: gold;"/>
''');

_positionElement(Element element, num x, num y) =>
  element
  ..attributes['x'] = '$x'
  ..attributes['y'] = '$y';

// end <timeline>
