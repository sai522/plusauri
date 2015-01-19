library t_f_partitions;
import 'dart:html' hide Timeline;
import 'dart:html';
import 'dart:math' show min, max, Point;
import 'dart:svg' as svg show Point;
import 'dart:svg' hide Point;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/models/common.dart' hide Point;
import 'package:polymer/polymer.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFPartitions");

@CustomTag("plus-t-f-partitions")
class TFPartitions extends PolymerElement {

  TFPartitions.created() : super.created() {
    _logger.fine('TFPartitions created sr => $shadowRoot');
    // custom <TFPartitions created>
    // end <TFPartitions created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFPartitions domReady with sr => $shadowRoot');
    // custom <TFPartitions domReady>
    // end <TFPartitions domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFPartitions ready with sr => $shadowRoot');
    // custom <TFPartitions ready>
    
    // end <TFPartitions ready>

  }

  @override
  void attached() {
    // custom <TFPartitions pre-attached>
    // end <TFPartitions pre-attached>

    super.attached();
    _logger.fine('TFPartitions attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFPartitions attached>
    _svgContainer..id = 'svg-container';
    _point = _svgContainer.createSvgPoint(); 

    // end <TFPartitions attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFPartitions)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFPartitions>

  get _width => _svgContainer.offsetWidth;
  get _height => _svgContainer.offsetHeight;
  get _innerWidth => _width - _leftMargin - _rightMargin;
  get _innerHeight => _height - _bottomMargin - _innerTop;

  setPartitions(PartitionMapping allocation,
      PartitionMapping style,
      PartitionMapping capitalization) {
    
    _allocationDetails =
      new PartitionDetails('allocation', $['allocation'], _svgContainer);
    _styleDetails =
      new PartitionDetails('style', $['style'], _svgContainer);
    _capitalizationDetails =
        new PartitionDetails('capitalization', $['capitalization'],
           _svgContainer);

     final partitions = [ _allocationDetails, _styleDetails,
       _capitalizationDetails ];
     
    _allocationDetails.partitionMapping = allocation;
    _styleDetails.partitionMapping = style;
    _capitalizationDetails.partitionMapping = capitalization;
    
     partitions.forEach((partition) {
           _group.nodes.add(partition._group);
           partition
             ._radioButton
             .onClick
             .listen((_) {
                   partitions
                     .where((p) => p != partition)
                     .forEach((p) => p._hideVisuals());
                   partition.selected();
                 });
         });

     _svgContainer.nodes.add(_group);
     _shellDiv = $['shell']..nodes.add(_svgContainer);
     _allocationDetails.selected();

    final graphBounds = new Rectangle(_innerLeft, _innerTop,
        _innerWidth, _innerHeight);

    final titleX = _innerWidth/2;
    final titleY = _topMargin;

    partitions
      .forEach
      ((partition) {
        partition._title.attributes
          ..['font-size'] = '$_titleFontSize'
          ..['font-weight'] = 'bold'
          ..['text-anchor'] = 'middle'
          ..['dominant-baseline'] = 'hanging';

        _positionElement(partition._title, titleX, titleY);

        partition.assumeDimensions(graphBounds);

        partition._verticalDividers.forEach
          ((divider) {

          });
      });          
  }

  // end <class TFPartitions>
  DivElement _header;
  SvgSvgElement _svgContainer = new SvgSvgElement();
  GElement _group = new GElement();
  DivElement _shellDiv;
  svg.Point _point;
  PartitionDetails _allocationDetails;
  PartitionDetails _styleDetails;
  PartitionDetails _capitalizationDetails;
  LineElement _verticalAxis = new LineElement();
  LineElement _horizontalAxis = new LineElement();
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}


class PartitionDetails {
  PartitionDetails(this._id, this._radioButton, this._svgContainer) {
    // custom <PartitionDetails>

    _title.innerHtml = _partitionTypeMap[_id]['title'];
    _hideVisuals();

    // end <PartitionDetails>
  }

  // custom <class PartitionDetails>

  assumeDimensions(Rectangle graphBounds) {
    assert(_partitionMapping != null);
    final numBars = _bars.length;

    if(numBars == 0) return;
    final labelWidth = 60;
    final originalHeight = graphBounds.height.toDouble();
    // adjust height by adding some internal visual whitespace (more if fewer bars)
    final adjustedHeight = originalHeight *
      (numBars < 2 ? 0.25 :
          (numBars < 3 ? 0.5 :
              (numBars < 4 ? 0.65 : 0.85)));

    final topOfChart = graphBounds.top + (originalHeight - adjustedHeight)/2.0;
    final numInterstices = numBars - 1;
    final percentForBars = 0.7;
    final heightForBars = adjustedHeight * percentForBars;
    final heightForInterstices = adjustedHeight * (1-percentForBars);
    final barHeight = heightForBars/numBars;
    final innerSpacing = heightForInterstices/numInterstices;
    final spacingStep = barHeight + innerSpacing;
    final displayWidth = graphBounds.width - labelWidth;
    final x = graphBounds.left + labelWidth;

    // Scale maximum percent to 85% of width
    final maxPct = _bars
      .map((bar) => bar._percent)
      .fold(0.0, (prev, pct) => max(prev, pct));
    final scalar = 0.65 * displayWidth / maxPct;

    //    var y = graphBounds.top;
    var y = topOfChart;
    // First iterate to find max x and store xEnd for rhs labels
    final xEnd =
      _rightLabelPad +
      x +
      _bars.reduce((BarDetails a, BarDetails b) =>
          a._percent.compareTo(b._percent) > 0 ? a : b)._percent *
      scalar;

    _bars.forEach(
      (bar) {
        bar._bar.attributes
          ..['x'] = '${x}'
          ..['y'] = '$y'
          ..['width'] = '${bar._percent*scalar}'
          ..['height'] = '$barHeight'
          ..['display'] = '';

        bar._bar.style
          //..setProperty('fill-opacity', '0.6')
          ..setProperty('stroke', '#130e14')
          ..setProperty('stroke-opacity', '1');

        final labelY = y + barHeight/6;
        _positionElement(bar._label, x - _leftLabelPad, labelY);
        _positionElement(bar._valueLabel, xEnd, labelY);
        y += spacingStep;
      });
  }

  set partitionMapping(PartitionMapping pm) {
    _partitionMapping = pm;
    _verticalDividers.clear();
    _bars.clear();
    _group.nodes.removeWhere((_) => true);
    _partitionMapping = pm;
    final map = pm.partitionMap;
    final totalValue = pm.total;
    final partitioned = pm.partitioned;

    map.forEach((String category, double percent) {
      final percentOfTotal = pm.percentOfTotal(category);
      double categoryValue = pm.value(category);
      _bars.add(new BarDetails()
          .._value = categoryValue
          .._percent = percentOfTotal
          ..setLabel(category));
      _maxPct = max(_maxPct, percentOfTotal);
      _minPct = min(_minPct, percentOfTotal);
    });

    if(pm.unpartitioned != 0.0) {
      _bars.add(
          new BarDetails()
             .._value = pm.unpartitioned
             .._percent = pm.percentUnpartitioned
             ..setLabel('unspecified'));
    }

    for(int i=0; i<4; i++)
      _verticalDividers.add(new VerticalDivider());

    if(_maxPct >= 0.0 || _minPct < 100.001) {
      _logger.warning('No information for charting partion on $pm');
    }

    _group.nodes
      ..add(_title)
      ..addAll(_bars
          .fold([], (prev, bar) => prev..addAll(bar.visuals)))
      ..addAll(_verticalDividers
          .fold([], (prev, vd) => prev..addAll(vd.visuals)));
  }

  selected() => _showVisuals();

  _hideVisuals() => _group.attributes['display'] = 'none';
  _showVisuals() => _group.attributes.remove('display');

  // end <class PartitionDetails>
  String _id;
  InputElement _radioButton;
  SvgSvgElement _svgContainer;
  TextElement _title = new TextElement();
  PartitionMapping _partitionMapping;
  Map _labelMap = {};
  GElement _group = new GElement();
  List<BarDetails> _bars = [];
  List<VerticalDivider> _verticalDividers = [];
  double _minPct = double.MAX_FINITE;
  double _maxPct = -double.MAX_FINITE;
}

class BarDetails {
  // custom <class BarDetails>

  BarDetails() {
    _label.attributes
      ..['font-size'] = '$_labelFontSize'
      ..['text-anchor'] = 'end'
      ..['dominant-baseline'] = 'hanging';

    _valueLabel.attributes
      ..['font-size'] = '$_labelFontSize'
      ..['text-anchor'] = 'start'
      ..['dominant-baseline'] = 'hanging';
  }

  get visuals => [ _bar, _label, _valueLabel ];

  setLabel(String label) {
    _label.innerHtml = label;
    _valueLabel.innerHtml = '${moneyShortForm(roundToNearest(_value, 3).toDouble())}';
    final barAttributes = _barAttributesMap[label];
    if(barAttributes != null) {
      _label.innerHtml = barAttributes['title'];
      _bar.style.setProperty('fill', barAttributes['color']);
    }
  }

  // end <class BarDetails>
  RectElement _bar = new RectElement();
  double _value = 0.0;
  double _percent = 0.0;
  TextElement _label = new TextElement();
  TextElement _valueLabel = new TextElement();
}

class VerticalDivider {
  // custom <class VerticalDivider>

  get visuals => [ _topLabel, _bottomLabel, _vertical ];

  assumeDimensions(num width, num height) {
    print('VD assuming $width, $height');
  }

  // end <class VerticalDivider>
  TextElement _topLabel = new TextElement();
  TextElement _bottomLabel = new TextElement();
  LineElement _vertical = new LineElement();
}


// custom <t_f_partitions>

get _leftMargin => 7;
get _innerLeft => _leftMargin;
get _rightMargin => 7;
get _topMargin => 7;
get _bottomMargin => 7;
get _titleFontSize => 14;
get _titleBottomMargin => 3;
get _innerTop => _topMargin + _titleFontSize + _titleBottomMargin;
get _labelFontSize => 12;
get _leftLabelPad => 5;
get _rightLabelPad => 5;

_positionElement(Element element, num x, num y) =>
  element
  ..attributes['x'] = '$x'
  ..attributes['y'] = '$y';

const _partitionTypeMap = const {
  'capitalization' : const {
    'title' : 'Capitalization Breakdown'
  },
  'style' : const {
    'title' : 'Investment Style Breakdown'
  },
  'allocation' : const {
    'title' : 'Investment Allocation Breakdown'
  }
};

const _barAttributesMap = const {
  'stock' : const {
    'color' : 'red',
    'title' : 'Stock',
  },
  'bond' : const {
    'color' : 'blue',
    'title' : 'Bond',
  },
  'cash' : const {
    'color' : 'green',
    'title' : 'Cash',
  },
  'other': const {
    'color' : 'darkgray',
    'title' : 'Other',
  },
  'smallCap' : const {
    'color' : 'red',
    'title' : 'Small',
  },
  'midCap' : const {
    'color' : 'green',
    'title' : 'Mid',
  },
  'largeCap' : const {
    'color' : 'blue',
    'title' : 'Large',
  },
  'value' : const {
    'color' : 'blue',
    'title' : 'Value',
  },
  'growth' : const {
    'color' : 'red',
    'title' : 'Growth',
  },
  'blend' : const {
    'color' : 'green',
    'title' : 'Blend',
  },

  'unspecified': const {
    'color' : 'lightgray',
    'title' : 'Unknown',
  },

};

// end <t_f_partitions>
