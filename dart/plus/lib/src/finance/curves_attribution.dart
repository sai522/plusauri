part of plus.finance;

class CurvesAttribution {
  CurvesAttribution(this._curvesAttribution);

  bool operator ==(CurvesAttribution other) => identical(this, other) ||
      const MapEquality().equals(_curvesAttribution, other._curvesAttribution);

  int get hashCode => const MapEquality().hash(_curvesAttribution).hashCode;

  Map<Object, RateCurve> get curvesAttribution => _curvesAttribution;
  // custom <class CurvesAttribution>

  Attribution scaleOnIntervals(DateRange dr, [AttributionAdjustor adjustor]) {
    Map result = valueApply(_curvesAttribution, (v) => 0.0);
    double netValue = 1.0;
    visitDateRange(dr, (Date start, Date end) {
      double rangeNet = netValue;
      _curvesAttribution.forEach((index, curve) {
        double net = netValue * (curve.scaleFromTo(start, end) - 1.0);
        result[index] += net;
        rangeNet += net;
      });
      //print('Processing $range => ($netValue -> $rangeNet)');
      netValue = rangeNet;
      if (adjustor != null) {
        netValue = adjustor(netValue, result);
      }
    });

    return attribution(result);
  }

  String toString() {
    List parts = [];
    _curvesAttribution.keys.toList()
      ..sort()
      ..forEach((id) => parts.add('${id} => ${_curvesAttribution[id]}'));
    return parts.join('\n');
  }

  // end <class CurvesAttribution>
  final Map<Object, RateCurve> _curvesAttribution;
}

/// Create a CurvesAttribution sans new, for more declarative construction
CurvesAttribution curvesAttribution(
    [Map<Object, RateCurve> _curvesAttribution]) =>
        new CurvesAttribution(_curvesAttribution);

class Attribution {
  Attribution(this._attribution);

  bool operator ==(Attribution other) => identical(this, other) ||
      const MapEquality().equals(_attribution, other._attribution);

  int get hashCode => const MapEquality().hash(_attribution).hashCode;

  Map<Object, double> get attribution => _attribution;
  // custom <class Attribution>

  totalValue([double value = 1.0]) =>
      (1.0 + _attribution.values.fold(0.0, (prev, net) => prev + net)) * value;

  contributionDelta(Object index, [double value = 1.0]) {
    double netScalar = _attribution[index];
    return (netScalar == null) ? 0.0 : netScalar * value;
  }

  String toString() {
    List parts = ['{'];
    _attribution.forEach((k, v) => parts.add('  $k => $v'));
    parts.add('}');
    parts.add('with total ${totalValue()}');
    return parts.join('\n');
  }

  operator [](Object index) => _attribution[index];

  // end <class Attribution>
  final Map<Object, double> _attribution;
}

/// Create a Attribution sans new, for more declarative construction
Attribution attribution([Map<Object, double> _attribution]) =>
    new Attribution(_attribution);
// custom <part curves_attribution>

typedef double AttributionAdjustor(double net, Map<Object, double> attribution);

// end <part curves_attribution>
