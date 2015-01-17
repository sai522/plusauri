library plus.date_value;

import 'dart:convert' as convert;
import 'package:plus/date.dart';
import 'package:quiver/core.dart';
// custom <additional imports>
// end <additional imports>

class DateValue
  implements Comparable<DateValue> {
  DateValue(this.date, this.value);

  bool operator==(DateValue other) =>
    identical(this, other) ||
    date == other.date &&
    value == other.value;

  int get hashCode => hash2(date, value);

  int compareTo(DateValue other) {
    int result = 0;
    ((result = date.compareTo(other.date)) == 0) &&
    ((result = value.compareTo(other.value)) == 0);
    return result;
  }

  copy() => new DateValue._copy(this);
  Date date;
  num value;
  // custom <class DateValue>

  bool isBefore(DateValue other) => date.isBefore(other.date);

  static DateValue fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    Map dv = json;
    return new DateValue(Date.fromJson(dv['date']),
        dv['value']);
  }

  Map toJson() => {
    'date' : date.toJson(),
    'value' : value
  };

  operator +(DateValue other) =>
    dateValue(maxDate(date, other.date),
        value + other.value);

  operator -() => dateValue(date, -value);

  toString() => '($date, $value)';
  
  // end <class DateValue>
  DateValue._copy(DateValue other) :
    date = other.date,
    value = other.value;

}

/// Create a DateValue sans new, for more declarative construction
DateValue
dateValue([Date date,
  num value]) =>
  new DateValue(date,
      value);

// custom <library date_value>

var dv = dateValue;

int _binarySearch(List<DateValue> list, Date date,
    [ int startIndex = 0 ]) {
  int max = list.length;
  int min = math.min(startIndex, max);

  while (min < max) {
    int mid = min + ((max - min) >> 1);
    DateValue element = list[mid];
    int comp = element.date.compareTo(date);
    if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  assert(max == min);
  return math.min(list.length-1, min);
}

int firstOnOrBefore(List<DateValue> list, Date date,
    [ int startIndex = 0 ]) {
  if(list.length == 0) return -1;
  int index = _binarySearch(list, date, startIndex);
  return (index < 0)? index :
    ((list[index].date.compareTo(date) > 0)? index-1 : index);
}

// end <library date_value>
