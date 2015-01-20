library basic_input.formatting;

import 'package:intl/intl.dart';
// custom <additional imports>
import 'dart:math';
// end <additional imports>

// custom <library formatting>

int _zero = "0".codeUnits[0];
int _nine = "9".codeUnits[0];
int _comma = ",".codeUnits[0];
int _dot = ".".codeUnits[0];
int _minus = "-".codeUnits[0];
int _lparen = "(".codeUnits[0];
int _rparen = ")".codeUnits[0];

bool _isNum(int i) => (i >= _zero && i <= _nine);
bool _isNumChar(int i) => (i >= _zero && i <= _nine) ||
  i == _lparen || i == _rparen || i == _dot || i == _minus;

num pullNum(String s, [num defaultValue]) {
  try {
    if(s.length == 0) return defaultValue;

    var numberChars = s.codeUnits.where((i) => _isNumChar(i)).toList();
    var lastIndex = numberChars.length-1;
    if(lastIndex < 0) return defaultValue;
    bool negative = false;
    if(numberChars[0] == "(".codeUnits[0]) {
      numberChars = numberChars.sublist(1, lastIndex);
      negative = true;
    }

    if(numberChars.length == 0 || s == '-' || s == '.') return defaultValue;
    s = new String.fromCharCodes(numberChars);
    final result = double.parse(s, (source) => defaultValue);
    return negative? -result : result;
  } catch(e) {
    return defaultValue;
  }
}

int pullInteger(String s) {
  var result = pullNum(s);
  return (result == null)? result : result.round();
}

String accountingNum(num i, [String dollarSign = r'$']) =>
  '$dollarSign${commifyNum(i)}';

String accountingInt(int i, [String dollarSign = r'$']) =>
  '$dollarSign${commifyInt(i)}';

String commifyInt(int i) =>
  i<0? "(${commify((-i).toString())})" : commify(i.toString());

String commifyNum(num n) {
  bool negative = n<0;
  String original = n.abs().toString();
  var found = original.indexOf('.');
  var result = found < 0 ?
    commify(original) :
    commify(original.substring(0, found)) + original.substring(found);
  return negative ? '($result)' : result;
}


RegExp _decimalNums = new RegExp(r"(\.\d+)");

var _currencyFormatTwoDecimals = new NumberFormat(r'$#,##0.00;$(#,##0.00)', "en");
var _currencyFormat = new NumberFormat(r'$#,##0;$(#,##0)', "en");
var _numberFormat = new NumberFormat(r'#,##0', "en");
var _percentFormat = new NumberFormat(r'#,##0.00%', "en");
var _percentIntFormat = new NumberFormat(r'#,##0%', "en");
var _basisPointFormat = new NumberFormat(r'#,##0.00 bps', "en");
var _yearsFormat = new NumberFormat(r'#,##0 years', "en");
var _monthsFormat = new NumberFormat(r'#,##0 months', "en");
var _dateFormat = new DateFormat('yyyy-MM-dd');
var _dateFormatMDY = new DateFormat('MM/dd/yyyy');

var _currencyFormatK = new NumberFormat(r'$#,##0.##K;$(#,##0.##)K', "en");
var _currencyFormatM = new NumberFormat(r'$#,##0.##M;$(#,##0.##)M', "en");
var _currencyFormatB = new NumberFormat(r'$#,##0.##B;$(#,##0.##)B', "en");
var _currencyFormatT = new NumberFormat(r'$#,##0.##B;$(#,##0.##)T', "en");

String numberFormat(num n) => _numberFormat.format(n);
String dateFormat(DateTime d) => _dateFormat.format(d);

var _defaultDate = new DateTime(1929, 10, 29);
var _dateFormatters = [ _dateFormat, _dateFormatMDY ];

DateTime pullDate(String s, [ DateTime defaultDate, bool utc = true ]) {
  DateTime result;
  _dateFormatters.any((df) {
    try {
      result = df.parse(s, utc);
      return true;
    } catch(e) {
      return false;
    }
  });
  return result == null? defaultDate : result;
}

double moneyRoundCent(num amount) =>
  (amount*100.0).round()/100.0;

int moneyRoundDollar(num amount) =>
  amount.round();

String moneyFormat(num n, [ bool showDecimals ]) =>
  ((showDecimals == null && (n.abs() <= 99999.9999)) ||
      showDecimals == true)?
  _currencyFormatTwoDecimals.format(n) :
  _currencyFormat.format(n);


int numDigits(num n) => (log(n)/LN10).ceil();

num _roundTo(num n, Rounder rounder, [ int digits = 2 ]) {
  if(n == 0) return 0;
  bool isNegative = n < 0;
  n = n.abs();
  final int nDigits = numDigits(n);
  double tmp = n.toDouble();
  int result;
  if(nDigits > digits) {
    final digitsShifted = nDigits - digits;
    final factor = pow(10, digitsShifted);
    tmp /= factor;
    result = rounder(tmp) * factor;
  } else {
    result = rounder(tmp);
  }
  return isNegative? -result : result;
}

num roundToNearest(num n, [ int digits = 2 ]) =>
  _roundTo(n, _nearestRounder, digits);

num roundToCeil(num n, [ int digits = 2 ]) =>
  n<0?
  _roundTo(n, _floorRounder, digits) :
  _roundTo(n, _ceilRounder, digits);

num roundToFloor(num n, [ int digits = 2 ]) =>
  n<0?
  _roundTo(n, _ceilRounder, digits) :
  _roundTo(n, _floorRounder, digits);

const THOUSAND = 1000;
const MILLION = 1000000;
const BILLION = 1000000000;
const TRILLION = 1000000000000;

String moneyShortForm(num n) {
  final absn = n.abs();
  return (absn < THOUSAND)? moneyFormat(n) :
    (absn < MILLION)? '${_currencyFormatK.format(n/THOUSAND)}' :
    (absn < BILLION)? '${_currencyFormatM.format(n/MILLION)}' :
    (absn < TRILLION)? '${_currencyFormatB.format(n/BILLION)}' :
    '${_currencyFormatT.format(n/TRILLION)}';
}

typedef int Rounder(num n);
int _nearestRounder(num n) => n.round();
int _ceilRounder(num n) => n.ceil();
int _floorRounder(num n) => n.floor();

String percentFormat(num n, [ bool showDecimals = true ] )
  => showDecimals? _percentFormat.format(n) : _percentIntFormat.format(n);
String basisPointFormat(num n) => _basisPointFormat.format(10000*n);
String yearsFormat(num n) => _yearsFormat.format(n);
String monthsFormat(num n) => _monthsFormat.format(n);
String shortYear(int year) => "'${(((year*100)%10000)/100).round()}";

String commify(String s) {
  int len = s.length;
  int commas = len~/3;
  if(len%3==0) commas -= 1;
  List<int> units = s.codeUnits.toList();
  for(int i=1; i<=commas; i++) {
    units.insert(len-(i*3), _comma);
  }
  return new String.fromCharCodes(units);
}

typedef String NumericValueConstraint(num);
typedef String StringValueConstraint(String);

// end <library formatting>
