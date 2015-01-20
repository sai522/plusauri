part of plus.finance;

class CFlowSequence {
  CFlowSequence.assumeSorted(this._flows);

  List<DateValue> get flows => _flows;
  // custom <class CFlowSequence>

  CFlowSequence([flows = const []]) : _flows = _sortFlows(flows);

  static _sortFlows(flows) => new List.from(flows)..sort();

  double valueOn(Date onDate, RateCurve curve) => _flows.fold(0.0,
      (prev, flow) => prev + flow.value * curve.scaleFromTo(flow.date, onDate));

  double valueOnFixedRate(Date onDate, double rate) {
    if (_flows.length == 0) return 0.0;
    Date rateStart = minDate(onDate, _flows[0].date);
    return valueOn(onDate, rateCurve([dv(rateStart, rate)]));
  }

  double get straightSum =>
      _flows.fold(0.0, (prev, flow) => (prev + flow.value));

  toString() => '${_flows}';

  // end <class CFlowSequence>
  final List<DateValue> _flows;
}

/// Create a CFlowSequence sans new, for more declarative construction
CFlowSequence cFlowSequenceAssumeSorted([List<DateValue> _flows]) =>
    new CFlowSequence.assumeSorted(_flows);
// custom <part cash_flow>

CFlowSequence cFlowSequence([List<DateValue> _flows]) =>
    new CFlowSequence(_flows);

// end <part cash_flow>
