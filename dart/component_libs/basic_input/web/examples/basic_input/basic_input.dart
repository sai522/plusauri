import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';
// custom <additional imports>

import 'dart:html';
import 'package:basic_input/components/money_input.dart';
import 'package:basic_input/components/num_with_units_input.dart';
import 'package:basic_input/components/simple_string_input.dart';
import 'package:basic_input/components/rate_input.dart';
import 'package:basic_input/components/date_input.dart';
import 'package:basic_input/components/menu_selector.dart';

// end <additional imports>


main() {
  Logger.root.onRecord.listen((LogRecord r) =>
    print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.FINEST;
  initPolymer().run(() {
    Polymer.onReady.then((var _) {
// custom <basicInput main>

  final mi = (document
    .querySelector('#sample-money-input') as MoneyInput)
    ..placeholder = 'Foobar';
  
  mi.onUpdate((Event event) => 
      print("Money Input updated: ${mi.amount}")
      );

  final nwi = (document
      .querySelector('#num-with-units-input') as NumWithUnitsInput);
  
  final ri = (document
      .querySelector('#sample-rate-input') as RateInput);

  final di = (document
      .querySelector('#sample-date-input') as DateInput);

  final selector = (document
      .querySelector('#sample-selector') as MenuSelector)
    ..selection = HoldingType.STOCK.toString()
    ..setOptions(HoldingType.values);

  final si = (document
    .querySelector('#simple-string-input') as SimpleStringInput)
    ..placeholder = 'Enter the simple string'
    ..valueConstraint = (String s) => s == 'complex' ? 'Complex is not simple' : null;


// end <basicInput main>

    });
  });
}

// custom <additional code>

class HoldingType implements Comparable<HoldingType> {
  static const OTHER = const HoldingType._(0);
  static const STOCK = const HoldingType._(1);
  static const BOND = const HoldingType._(2);
  static const CASH = const HoldingType._(3);
  static const BLEND = const HoldingType._(4);

  static get values => [
    OTHER,
    STOCK,
    BOND,
    CASH,
    BLEND
  ];

  final int value;

  int get hashCode => value;

  const HoldingType._(this.value);

  copy() => this;

  int compareTo(HoldingType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case OTHER: return "Other";
      case STOCK: return "Stock";
      case BOND: return "Bond";
      case CASH: return "Cash";
      case BLEND: return "Blend";
    }
    return null;
  }

  static HoldingType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Other": return OTHER;
      case "Stock": return STOCK;
      case "Bond": return BOND;
      case "Cash": return CASH;
      case "Blend": return BLEND;
      default: return null;
    }
  }

  int toJson() => value;
  static HoldingType fromJson(int v) {
    return v==null? null : values[v];
  }
}


// end <additional code>

