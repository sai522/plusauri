part of plus.finance;

class RateCurve {
  RateCurve.assumeSorted(this._curveData);

  bool operator ==(RateCurve other) => identical(this, other) ||
      const ListEquality().equals(_curveData, other._curveData);

  int get hashCode => const ListEquality<DateValue>().hash(_curveData).hashCode;

  List<DateValue> get curveData => _curveData;
  // custom <class RateCurve>

  RateCurve copy() =>
      new RateCurve(new List.from(_curveData.map((dv) => dv.copy())));

  RateCurve([data = const []]) : _curveData = _sortData(data);

  toString() => '${_curveData}';

  get length => _curveData.length;

  num getRate(Date asOf) {
    return _getDateValue(asOf).value;
  }

  operator *(num scalar) {
    List<DateValue> guts = [];
    for (int i = 0; i < _curveData.length; i++) {
      guts.add(dv(_curveData[i].date, _curveData[i].value * scalar));
    }
    return new RateCurve(guts);
  }

  operator /(num scalar) {
    List<DateValue> guts = [];
    for (int i = 0; i < _curveData.length; i++) {
      guts.add(dv(_curveData[i].date, _curveData[i].value / scalar));
    }
    return new RateCurve(guts);
  }

  operator +(num scalar) {
    List<DateValue> guts = [];
    for (int i = 0; i < _curveData.length; i++) {
      guts.add(dv(_curveData[i].date, _curveData[i].value + scalar));
    }
    return new RateCurve(guts);
  }

  operator -(num scalar) => this + -scalar;

  static RateCurve merge(final RateCurve c1, final RateCurve c2) {
    if (c1.length == 0) return c2;
    if (c2.length == 0) return c1;
    List<DateValue> result = [];
    DateValue next = dv(new Date(1, 1, 1), 0.0);
    int c1Len = c1.length;
    int c2Len = c2.length;
    int c1i = 0,
        c2i = 0;
    double c1Last = 0.0,
        c2Last = 0.0,
        lastMerged = 0.0;

    while (c1i < c1Len || c2i < c2Len) {
      bool useLeft = ((c2i == c2Len) ||
          ((c1i < c1Len) && (c1._curveData[c1i].isBefore(c2._curveData[c2i]))));

      if (useLeft) {
        next = c1._curveData[c1i++].copy();
        lastMerged += next.value - c1Last;
        c1Last = next.value;
      } else {
        next = c2._curveData[c2i++].copy();
        lastMerged += next.value - c2Last;
        c2Last = next.value;
      }

      next.value = lastMerged;
      _append(result, dv(next.date, next.value));
    }
    return new RateCurve.assumeSorted(result);
  }

  double revalueOn(DateValue dv, Date targetDate) =>
      scaleFromTo(dv.date, targetDate) * dv.value;

  double scaleFromTo(Date start, Date end) {
    if (start > end) {
      return 1.0 / scaleFromTo(end, start);
    }
    double value = 1.0;
    if (_curveData.length == 0) return value;
    Date currentDate = start;

    int startIndex = firstOnOrBefore(_curveData, start);
    if (startIndex < 0) {
      startIndex = 0;
      currentDate = _curveData[0].date;
    }

    int endIndex = firstOnOrBefore(_curveData, end, startIndex);
    if (endIndex < 0) return value;

    for (int i = startIndex; i < endIndex; i++) {
      var rate = _curveData[i].value;
      var endDate = _curveData[i + 1].date;
      value = moveValueInTime(value, rate, currentDate, endDate);
      currentDate = endDate;
    }

    if (currentDate < end) {
      var rate = _curveData[endIndex].value;
      value = moveValueInTime(value, rate, currentDate, end);
    }

    return value;
  }

  static _sortData(curveData) => new List.from(curveData)..sort();

  DateValue _getDateValue(Date asOf) {
    int index = firstOnOrBefore(_curveData, asOf);
    if (index < 0) {
      return dv(asOf, 0.0);
    } else {
      return _curveData[index];
    }
  }

  static _append(List<DateValue> data, DateValue dv) {
    if (data.length == 0) {
      data.add(dv);
    } else {
      var last = data.last;
      if (last.date == dv.date) {
        last.value = dv.value;
      } else {
        if (last.value != dv.value) {
          data.add(dv);
        }
      }
    }
    if (data.length == 1 && data[0].value == 0.0) data.clear();
  }

  Map toJson() {
    return {"curveData": ebisu_utils.toJson(curveData),};
  }

  static RateCurve fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    var curveData = [];
    (json as Map)["curveData"].forEach((v) {
      curveData.add(DateValue.fromJson(v));
    });
    return rateCurve(curveData);
  }

  // end <class RateCurve>
  final List<DateValue> _curveData;
}
// custom <part rate_curve>

RateCurve rateCurve([List<DateValue> curveData = const []]) =>
    new RateCurve(curveData);

typedef CurveAdjuster(RateCurve curve);

final ZeroRateCurve = rateCurve();

// end <part rate_curve>
