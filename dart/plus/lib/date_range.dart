library plus.date_range;

import 'dart:convert' as convert;
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:plus/date.dart';
import 'package:quiver/core.dart';
// custom <additional imports>
// end <additional imports>

class YearRange {
  YearRange(this._start, this._end) { _init(); }

  int get start => _start;
  int get end => _end;
  // custom <class YearRange>

  _init() {
    if(_start > _end)
      throw new
        ArgumentError("Year range start $start must be on or before end $end");
  }

  DateRange get dateRange =>
    new DateRange(startOfYear(_start), startOfYear(_end));

  int get years => _end - _start;
  
  // end <class YearRange>
  final int _start;
  final int _end;
}

class DateRange
  implements Comparable<DateRange> {
  DateRange(this._start, this._end) {
    // custom <DateRange>
    if(_start > _end)
      throw new
        ArgumentError("Date range start $start must be on or before end $end");
    // end <DateRange>
  }

  bool operator==(DateRange other) =>
    identical(this, other) ||
    _start == other._start &&
    _end == other._end;

  int get hashCode => hash2(_start, _end);

  int compareTo(DateRange other) {
    int result = 0;
    ((result = _start.compareTo(other._start)) == 0) &&
    ((result = _end.compareTo(other._end)) == 0);
    return result;
  }

  copy() => new DateRange._copy(this);
  Date get start => _start;
  Date get end => _end;
  // custom <class DateRange>
  String toString() => '($start => $end)';

  bool isStrictlyBefore(DateRange other) =>
    _end <= other._start;

  /**
   * Returns true if the range contains the date
   */
  bool contains(Date d) =>
    d >= _start && d < _end;

  /**
   * Returns true if the range contains __any part__ of that year
   */
  bool containsYear(int year) =>
    year >= _start.year && year < _end.year;

  // end <class DateRange>

  Map toJson() => {
      "start": ebisu_utils.toJson(start),
      "end": ebisu_utils.toJson(end),
  };

  static DateRange fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new DateRange._fromJsonMapImpl(json);
  }

  DateRange._fromJsonMapImpl(Map jsonMap) :
    _start = Date.fromJson(jsonMap["start"]),
    _end = Date.fromJson(jsonMap["end"]);

  DateRange._copy(DateRange other) :
    _start = other._start,
    _end = other._end;

  Date _start;
  Date _end;
}

/// Create a DateRange sans new, for more declarative construction
DateRange
dateRange([Date _start,
  Date _end]) =>
  new DateRange(_start,
      _end);

class IntervalDateRange {
  const IntervalDateRange(this._start, this._end, this._frequency,
    this._dateRanges);

  bool operator==(IntervalDateRange other) =>
    identical(this, other) ||
    _start == other._start &&
    _end == other._end &&
    _frequency == other._frequency &&
    const ListEquality().equals(_dateRanges, other._dateRanges);

  int get hashCode => hash4(_start,
    _end,
    _frequency,
    const ListEquality<DateRange>().hash(_dateRanges));

  copy() => new IntervalDateRange._copy(this);
  Date get start => _start;
  Date get end => _end;
  Frequency get frequency => _frequency;
  List<DateRange> get dateRanges => _dateRanges;
  // custom <class IntervalDateRange>

  factory IntervalDateRange.basic(Date _start, Date _end, [ Frequency _frequency = ANNUAL ]) {
    var _dateRanges = [];
    if(_start > _end)
      throw new ArgumentError("IntervalDateRange start $_start must <= $_end");

    visitDateRange(new DateRange(_start, _end),
        (Date start, Date end) => _dateRanges.add(dateRange(start, end)),
        _frequency);

    return new IntervalDateRange(_start, _end, _frequency, _dateRanges);
  }


  String toString() => '''
start: $_start
end: $_end
frequency: $_frequency
dateRanges:\n\t${_dateRanges.join('\n\t')}
''';


  get numIntervals => _dateRanges.length;

  // end <class IntervalDateRange>
  IntervalDateRange._copy(IntervalDateRange other) :
    _start = other._start,
    _end = other._end,
    _frequency = other._frequency == null? null : other._frequency.copy(),
    _dateRanges = other._dateRanges == null? null :
      (new List.from(other._dateRanges.map((e) =>
        e == null? null : e.copy())));

  final Date _start;
  final Date _end;
  final Frequency _frequency;
  final List<DateRange> _dateRanges;
}

// custom <library date_range>
IntervalDateRange intervalDateRange(Date _start, Date _end, [ Frequency _frequency ]) =>
  new IntervalDateRange.basic(_start, _end,
  _frequency == null? Frequency.ANNUAL : _frequency);

fiscalRange(int year) => dateRange(startOfYear(year), startOfYear(year+1));

bool overlap(DateRange dr1, DateRange dr2) =>
  dr1.start < dr2.start?
      (dr1.end > dr2.start) : (dr2.end > dr1.start);

oneDayRange(Date d) => dateRange(d, d.nextDay);

typedef DateRangeVisitor(Date start, Date end);

void visitDateRange(DateRange dateRange, DateRangeVisitor visitor,
    [Frequency frequency]) {
  final start = dateRange.start;
  final end = dateRange.end;
  if(frequency == null) {
    frequency = Frequency.ANNUAL;
  }

  if(frequency == Frequency.ONCE) {
    visitor(start, end);
  } else {
    int startDayOfMonth = start.day;
    Date nextDate = start;
    Date nextNextDate = advanceDate(frequency, nextDate, startDayOfMonth);

    while(nextDate.isBefore(end)) {
      Date safeEnd = minDate(end, nextNextDate);
      visitor(nextDate, safeEnd);
      nextDate = nextNextDate;
      nextNextDate = advanceDate(frequency, nextDate, startDayOfMonth);
    }
  }
}

// end <library date_range>
