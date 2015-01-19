library plus.time_series;

import 'dart:convert' as convert;
import 'package:collection/equality.dart';
import 'package:logging/logging.dart';
import 'package:plus/binary_search.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart' as dv show firstOnOrBefore;
import 'package:plus/date_value.dart' hide firstOnOrBefore;
import 'package:quiver/core.dart';
// custom <additional imports>

import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:plus/finance.dart';

// end <additional imports>

final _logger = new Logger('time_series');

class TimeSeries {
  TimeSeries(this._data) {
    // custom <TimeSeries>
    assert(isOrdered);
    // end <TimeSeries>
  }

  bool operator==(TimeSeries other) =>
    identical(this, other) ||
    const ListEquality().equals(_data, other._data);

  int get hashCode => const ListEquality<DateValue>().hash(_data).hashCode;

  copy() => new TimeSeries._copy(this);
  List<DateValue> get data => _data;
  // custom <class TimeSeries>

  TimeSeries.fromIterable(Iterable<DateValue> src) : _data = new List.from(src);

  String toString() => 'TS[\n  ${_data.join("\n  ")}]';

  DateValue operator [](int i) => _data[i];

  double get sum => _data.fold(0.0, (prev, element) => prev + element.value);

  DateValue firstOnOrBefore(Date asOf, [int startIndex = 0]) {
    var found = dv.firstOnOrBefore(_data, asOf, startIndex);
    return found == -1 ? null : _data[found];
  }

  DateValue get sumToEnd {
    var result = dateValue();
    if (_data.length > 0) {
      result
          ..date = _data.last.date
          ..value = sum;
    }
    return result;
  }

  double sumToDateOnCurve(Date asOf, RateCurve curve) =>
      _data.fold(0.0, (prev, elm) => prev + curve.revalueOn(elm, asOf));

  int get length => _data.length;

  filterOnRange(DateRange range) =>
      _data.skipWhile(
          (dv) => dv.date < range.start).takeWhile((dv) => dv.date < range.end);

  filterOnYear(int year) =>
      _data.skipWhile(
          (dv) => dv.date.year < year).takeWhile((dv) => dv.date.year == year);

  Map toJson() {
    return {
      "data": ebisu_utils.toJson(data),
    };
  }

  static TimeSeries fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    var data = [];
    ((json as Map)["data"] as List).forEach((v) {
      data.add(DateValue.fromJson(v));
    });
    return timeSeries(data);
  }

  bool get isOrdered {
    for (int i = 1; i < _data.length; i++) {
      if (_data[i - 1].date > _data[i].date) return false;
    }
    return true;
  }

  // end <class TimeSeries>
  TimeSeries._copy(TimeSeries other) :
    _data = other._data == null? null :
      (new List.from(other._data.map((e) =>
        e == null? null : e.copy())));

  final List<DateValue> _data;
}

/// Create a TimeSeries sans new, for more declarative construction
TimeSeries
timeSeries([List<DateValue> _data]) =>
  new TimeSeries(_data);

// custom <library time_series>

splice(TimeSeries ts1, TimeSeries ts2) =>
    timeSeries(merge(ts1._data, ts2._data));


// end <library time_series>
