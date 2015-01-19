library plus.date;

import 'dart:math';
import 'package:quiver/core.dart';
// custom <additional imports>
// end <additional imports>

/// Frequency, for example of payments, for IntervalDateRanges
class Frequency implements Comparable<Frequency> {
  static const ONCE = const Frequency._(0);
  static const MONTHLY = const Frequency._(1);
  static const SEMIANNUAL = const Frequency._(2);
  static const ANNUAL = const Frequency._(3);

  static get values => [
    ONCE,
    MONTHLY,
    SEMIANNUAL,
    ANNUAL
  ];

  final int value;

  int get hashCode => value;

  const Frequency._(this.value);

  copy() => this;

  int compareTo(Frequency other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case ONCE: return "Once";
      case MONTHLY: return "Monthly";
      case SEMIANNUAL: return "Semiannual";
      case ANNUAL: return "Annual";
    }
    return null;
  }

  static Frequency fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Once": return ONCE;
      case "Monthly": return MONTHLY;
      case "Semiannual": return SEMIANNUAL;
      case "Annual": return ANNUAL;
      default: return null;
    }
  }

  int toJson() => value;
  static Frequency fromJson(int v) {
    return v==null? null : values[v];
  }

}

const ONCE = Frequency.ONCE;
const MONTHLY = Frequency.MONTHLY;
const SEMIANNUAL = Frequency.SEMIANNUAL;
const ANNUAL = Frequency.ANNUAL;

class Date
  implements Comparable<Date> {
  bool operator==(Date other) =>
    identical(this, other) ||
    _dateTime == other._dateTime;

  int get hashCode => _dateTime.hashCode;

  int compareTo(Date other) =>
    _dateTime.compareTo(other._dateTime);

  DateTime get dateTime => _dateTime;
  // custom <class Date>

  Date(int year, int month, int day)
      : _dateTime = new DateTime.utc(year, month, day);

  Date.fromDateTime(DateTime dt)
      : _dateTime = new DateTime.utc(dt.year, dt.month, dt.day) {
    assert(dt.isUtc);
  }


  String toString() => _dateTime.toString().substring(0, 10);
  String toJson() => toString();

  static Date fromJson(String dt) {
    if (dt == null) return null;
    var d = DateTime.parse(dt);
    return new Date(d.year, d.month, d.day);
  }


  int get year => _dateTime.year;
  int get month => _dateTime.month;
  int get day => _dateTime.day;

  bool operator <(Date other) => _dateTime.isBefore(other._dateTime);
  bool operator <=(Date other) =>
      _dateTime.isBefore(other._dateTime) || _dateTime == other.dateTime;
  bool operator >(Date other) => !(this <= other);
  bool operator >=(Date other) => !(this < other);

  Duration difference(Date other) => _dateTime.difference(other._dateTime);

  operator -(Date other) => _dateTime.difference(other._dateTime);

  Date get nextDay =>
      new Date.fromDateTime(_dateTime.add(const Duration(days: 1)));
  Date get nextYear =>
      new Date(_dateTime.year + 1, _dateTime.month, _dateTime.day);
  Date get priorDay =>
      new Date.fromDateTime(_dateTime.add(const Duration(days: -1)));
  Date get startOfYear => new Date(_dateTime.year, 1, 1);
  Date get endOfYear => new Date(_dateTime.year, 12, 31);
  Date get startOfNextYear => new Date(_dateTime.year + 1, 1, 1);
  Date get startOfPriorYear => new Date(_dateTime.year - 1, 1, 1);
  int get priorYear => _dateTime.year - 1;

  bool isBefore(Date other) => _dateTime.isBefore(other._dateTime);

  // end <class Date>
  final DateTime _dateTime;
}

// custom <library date>

final EarliestDate = new Date(1, 1, 1);

minDate(Date d1, Date d2) => d1 < d2 ? d1 : d2;
maxDate(Date d1, Date d2) => d1 < d2 ? d2 : d1;
date(int year, int month, int day) => new Date(year, month, day);
dateFromString(String date) => Date.fromJson(date);
startOfYear(int year) => date(year, 1, 1);
startOfNextYear(int year) => date(year + 1, 1, 1);
endOfYear(int year) => date(year, 12, 31);
get today => new Date.fromDateTime(new DateTime.now().toUtc());

bool isLeapYear(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }
  return false;
}

Date endOfMonthCheck(int year, int month, int day) {
  switch (month) {
    // 30 days has september, april, june and november
    case 9:
    case 4:
    case 6:
    case 11:
      return new Date(year, month, min(30, day));
    case 2:
      return new Date(year, month, min(isLeapYear(year) ? 29 : 28, day));
    default:
      return new Date(year, month, day);
  }
}

Date advanceDate(Frequency frequency, Date date, [int desiredDay]) {
  if (desiredDay == null) desiredDay = date.day;

  switch (frequency) {
    case Frequency.ONCE:
      return date;
    case Frequency.MONTHLY:
      final month = date.month + 1;
      return endOfMonthCheck(date.year, month, desiredDay);
    case Frequency.SEMIANNUAL:
      var month = date.month;
      final year = date.year + month ~/ 6;
      month = (month + 6) % 12;
      return endOfMonthCheck(year, month, desiredDay);
    case Frequency.ANNUAL:
      return endOfMonthCheck(date.year + 1, date.month, desiredDay);
    default:
      throw new StateError("Unexpected frequency $frequency");
  }
}

// end <library date>
