library timeline_forecast.year_axis;

import 'dart:async';
import 'dart:html';
import 'dart:math' show min, max, Point;
import 'dart:svg' as svg show Point;
import 'dart:svg' hide Point;
// custom <additional imports>
// end <additional imports>

class YearAxis {
  YearAxis(this._startYear, this._endYear) {
    // custom <YearAxis>

    if (_endYear < _startYear) throw new ArgumentError(
        "End year $_endYear is after start year $_startYear");

    _numYears = _endYear - _startYear;

    _yearTopLabels.length = _yearBottomLabels.length =
        _yearPositions.length = _yearLines.length = _numYearLines;

    _createYearItems();

    // end <YearAxis>
  }

  // custom <class YearAxis>

  _yearText(int year) => "'${(((year*100)%10000)/100).round()}";

  int get _numYearLines => _numYears + 1;

  double xForYearEnd(int year) {
    assert(year < _endYear && year >= _startYear);
    int index = year - _startYear + 1;
    assert(index < _yearPositions.length);
    return _xNum(_yearPositions[index]);
  }

  double yFromBase(double height) => _bottomLineY - height;
  double get bottomLineY => _bottomLineY;
  double get topLineY => _topLineY;

  styleHorizontalLine(line) => line.attributes['style'] =
      'stroke:rgb(0,0,0);stroke-width:2;stroke-opacity:0.4';

  addYLabel(double scalarY, String label) {
    _group.nodes.add(new TextElement()
      ..text = label
      ..attributes['dominant-baseline'] = 'middle'
      ..attributes['text-anchor'] = 'end'
      ..attributes['font-size'] = '9');

    _leftLabelElements[scalarY] = _group.nodes.last;
  }

  _createYearItems() {
    for (int i = 0; i < _numYearLines; i++) {
      var year = _yearText(_startYear + i);
      _yearTopLabels[i] = new TextElement()
        ..innerHtml = year
        ..attributes['font-size'] = _fontSize
        ..attributes['text-anchor'] = 'middle';

      _group.nodes.add(_yearTopLabels[i]);

      _yearBottomLabels[i] = new TextElement()
        ..innerHtml = year
        ..attributes['font-size'] = _fontSize
        ..attributes['text-anchor'] = 'middle'
        ..attributes['dominant-baseline'] = 'hanging';
      _group.nodes.add(_yearBottomLabels[i]);

      _yearLines[i] = new LineElement()
        ..attributes['style'] =
        'stroke-dasharray: 4 2; stroke:rgb(0,0,0);stroke-width:1;stroke-opacity:0.4';
      _group.nodes.add(_yearLines[i]);
    }

    [_topLine, _bottomLine].forEach((line) {
      styleHorizontalLine(line);
      _group.nodes.add(line);
    });

    _group.nodes.add(_highlightRect);
  }

  yearIndexFromX(double x) =>
      (((x + 0.0001 - _xNum(0)) / (_innerDim.x)) * _numYears).floor();

  yearFromX(double x) => _startYear + yearIndexFromX(x);

  mouseMove(point) {
    var calculatedIndex = yearIndexFromX(point.x);
    if (calculatedIndex >= 0 && calculatedIndex < _numYears) {
      if (_calculatedIndex != calculatedIndex) {
        _highlightRect
          ..attributes['style'] =
          'fill:#f7f7af;fill-opacity:0.8;stroke:#130e14;stroke-opacity:1'
          ..attributes['x'] = _x(_yearPositions[calculatedIndex])
          ..attributes['y'] = '$_topLineY'
          ..attributes['width'] = '$_yearWidth'
          ..attributes['height'] = '${_bottomLineY - _topLineY}'
          ..attributes['display'] = '';
        _calculatedIndex = calculatedIndex;
      }
      _highlightRect.attributes['display'] = '';
    } else {
      hideHighlightRectangle();
    }
  }

  hideHighlightRectangle() {
    _highlightRect.attributes['display'] = 'none';
  }

  calculateYearPositions() {
    double pos = 0.0;
    for (int i = 0; i < _numYearLines; i++) {
      _yearPositions[i] = pos;
      pos += _yearWidth;
    }
  }

  _xNum(num n) => _start.x + _leftMargin + n;
  _yNum(num n) => _start.y + _topMargin + n;
  _x(num n) => '${_xNum(n)}';
  _y(num n) => '${_yNum(n)}';

  positionItems() {
    _topLine
      ..attributes['x1'] = _x(0)
      ..attributes['x2'] = _x(_innerDim.x)
      ..attributes['y1'] = '$_topLineY'
      ..attributes['y2'] = '$_topLineY';

    _bottomLine
      ..attributes['x1'] = _x(0)
      ..attributes['x2'] = _x(_innerDim.x)
      ..attributes['y1'] = '$_bottomLineY'
      ..attributes['y2'] = '$_bottomLineY';

    for (int i = 0; i < _numYearLines; i++) {
      var x = _x(_yearPositions[i]);
      _yearLines[i]
        ..attributes['x1'] = x
        ..attributes['x2'] = x
        ..attributes['y1'] = '$_topLineY'
        ..attributes['y2'] = '$_bottomLineY';
      _yearTopLabels[i]
        ..attributes['x'] = x
        ..attributes['y'] = '$_topLabelY';
      _yearBottomLabels[i]
        ..attributes['x'] = x
        ..attributes['y'] = '$_bottomLabelY';
    }

    _leftLabelElements.forEach((scalarY, elm) {
      elm
        ..attributes['x'] = '${_start.x - 10}'
        ..attributes['y'] = '${topLabelY + (bottomLabelY - topLabelY)*scalarY}';
    });
  }

  scaleToSize(Point start, num width, num height) {
    _start = start;
    _width = width;
    _height = height;
    _bottomLineY = _start.y + _height - _bottomMargin;
    _topLineY = _start.y + _topMargin;
    _innerDim = new Point(
        _width - _leftMargin - _rightMargin, _bottomLineY - _topLineY);
    _yearWidth = _innerDim.x / _numYears;
    _topLabelY = _start.y + _topMargin - _yearToLinePad;
    _bottomLabelY = _bottomLineY + _yearToLinePad;
    calculateYearPositions();
    positionItems();
    new Timer(const Duration(milliseconds: 30), () {
      //print("NOW: BBOX ${_yearBottomLabels[0].getBBox().width} and ${_yearBottomLabels[0].offsetWidth}");
    });
  }

  GElement get group => _group;
  double get width => _width;
  double get height => _height;
  double get innerHeight => _innerDim.y;
  double get topLabelY => _topLabelY;
  double get bottomLabelY => _bottomLabelY;

  double get totalWidth => _leftMargin + _width + _rightMargin;
  double get totalHeight => _topMargin + _height + _bottomMargin;

  // end <class YearAxis>
  /// Starting offset for the axis within svg
  Point _start = new Point(0.0, 0.0);
  int _startYear = 0;
  int _endYear = 0;
  GElement _group = new GElement();
  double _width = 0.0;
  Point _innerDim = new Point(0.0, 0.0);
  double _height = 100.0;
  int _numYears = 0;
  double _yearWidth = 0.0;
  List<num> _yearPositions = [];
  List<TextElement> _yearTopLabels = [];
  List<TextElement> _yearBottomLabels = [];
  LineElement _topLine = new LineElement();
  LineElement _bottomLine = new LineElement();
  List<LineElement> _yearLines = [];
  double _yearToLinePad = 2.0;
  String _fontSize = '9';
  double _topMargin = 9.0;
  double _bottomMargin = 9.0;
  double _leftMargin = 7.0;
  double _rightMargin = 7.0;
  double _topLineY = 0.0;
  double _bottomLineY = 0.0;
  double _topLabelY = 0.0;
  double _bottomLabelY = 0.0;
  RectElement _highlightRect = new RectElement();
  int _calculatedIndex = -1;
  Map<double, TextElement> _leftLabelElements = {};
}

// custom <library year_axis>

bool rectContainsPoint(RectElement rect, Point p) =>
    p.y >= rect.y.baseVal.value &&
        p.y <= rect.y.baseVal.value + rect.height.baseVal.value &&
        p.x >= rect.x.baseVal.value &&
        p.x <= rect.x.baseVal.value + rect.width.baseVal.value;

// end <library year_axis>
