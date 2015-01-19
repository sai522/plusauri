library plus.portfolio;

import 'dart:async';
import 'dart:collection';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:basic_input/formatting.dart';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/binary_search.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/map_utilities.dart';
import 'package:plus/time_series.dart';
import 'package:quiver/core.dart';
// custom <additional imports>
// end <additional imports>

part 'src/portfolio/account.dart';
part 'src/portfolio/portfolio.dart';
part 'src/portfolio/trade_journal.dart';

final _logger = new Logger('portfolio');

class TradeType implements Comparable<TradeType> {
  static const BUY = const TradeType._(0);
  static const SELL = const TradeType._(1);

  static get values => [
    BUY,
    SELL
  ];

  final int value;

  int get hashCode => value;

  const TradeType._(this.value);

  copy() => this;

  int compareTo(TradeType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case BUY: return "Buy";
      case SELL: return "Sell";
    }
    return null;
  }

  static TradeType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Buy": return BUY;
      case "Sell": return SELL;
      default: return null;
    }
  }

  int toJson() => value;
  static TradeType fromJson(int v) {
    return v==null? null : values[v];
  }

}

const BUY = TradeType.BUY;
const SELL = TradeType.SELL;

/// Breakdown of capitalization
class Capitalization implements Comparable<Capitalization> {
  static const LARGE_CAP = const Capitalization._(0);
  static const MID_CAP = const Capitalization._(1);
  static const SMALL_CAP = const Capitalization._(2);

  static get values => [
    LARGE_CAP,
    MID_CAP,
    SMALL_CAP
  ];

  final int value;

  int get hashCode => value;

  const Capitalization._(this.value);

  copy() => this;

  int compareTo(Capitalization other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case LARGE_CAP: return "LargeCap";
      case MID_CAP: return "MidCap";
      case SMALL_CAP: return "SmallCap";
    }
    return null;
  }

  static Capitalization fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "LargeCap": return LARGE_CAP;
      case "MidCap": return MID_CAP;
      case "SmallCap": return SMALL_CAP;
      default: return null;
    }
  }

  int toJson() => value;
  static Capitalization fromJson(int v) {
    return v==null? null : values[v];
  }

}

const LARGE_CAP = Capitalization.LARGE_CAP;
const MID_CAP = Capitalization.MID_CAP;
const SMALL_CAP = Capitalization.SMALL_CAP;

/// Style of fund investment
class InvestmentStyle implements Comparable<InvestmentStyle> {
  static const VALUE = const InvestmentStyle._(0);
  static const BLEND = const InvestmentStyle._(1);
  static const GROWTH = const InvestmentStyle._(2);

  static get values => [
    VALUE,
    BLEND,
    GROWTH
  ];

  final int value;

  int get hashCode => value;

  const InvestmentStyle._(this.value);

  copy() => this;

  int compareTo(InvestmentStyle other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case VALUE: return "Value";
      case BLEND: return "Blend";
      case GROWTH: return "Growth";
    }
    return null;
  }

  static InvestmentStyle fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Value": return VALUE;
      case "Blend": return BLEND;
      case "Growth": return GROWTH;
      default: return null;
    }
  }

  int toJson() => value;
  static InvestmentStyle fromJson(int v) {
    return v==null? null : values[v];
  }

}

const VALUE = InvestmentStyle.VALUE;
const BLEND = InvestmentStyle.BLEND;
const GROWTH = InvestmentStyle.GROWTH;

/// Determines how sales close out lots
class LotCloseMethod implements Comparable<LotCloseMethod> {
  static const FIFO = const LotCloseMethod._(0);
  static const LIFO = const LotCloseMethod._(1);
  static const HIFO = const LotCloseMethod._(2);
  static const LOW_COST = const LotCloseMethod._(3);
  static const AVERAGE_COST = const LotCloseMethod._(4);

  static get values => [
    FIFO,
    LIFO,
    HIFO,
    LOW_COST,
    AVERAGE_COST
  ];

  final int value;

  int get hashCode => value;

  const LotCloseMethod._(this.value);

  copy() => this;

  int compareTo(LotCloseMethod other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case FIFO: return "Fifo";
      case LIFO: return "Lifo";
      case HIFO: return "Hifo";
      case LOW_COST: return "LowCost";
      case AVERAGE_COST: return "AverageCost";
    }
    return null;
  }

  static LotCloseMethod fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Fifo": return FIFO;
      case "Lifo": return LIFO;
      case "Hifo": return HIFO;
      case "LowCost": return LOW_COST;
      case "AverageCost": return AVERAGE_COST;
      default: return null;
    }
  }

  int toJson() => value;
  static LotCloseMethod fromJson(int v) {
    return v==null? null : values[v];
  }

}

const FIFO = LotCloseMethod.FIFO;
const LIFO = LotCloseMethod.LIFO;
const HIFO = LotCloseMethod.HIFO;
const LOW_COST = LotCloseMethod.LOW_COST;
const AVERAGE_COST = LotCloseMethod.AVERAGE_COST;

abstract class PriceResolver {
  // custom <class PriceResolver>

  Future<PRResults> resolvePrices(PRRequest request);

  // end <class PriceResolver>
}

class PRResults {
  PRResults(this.prices);

  PRResults._default();

  Map<String,TimeSeries> prices;
  // custom <class PRResults>

  toString() {
    List result = ['\t'];
    prices.forEach((k, v) => result.add('$k => $v'));
    return result.join('\n........');
  }

  // end <class PRResults>

  Map toJson() => {
      "prices": ebisu_utils.toJson(prices),
  };

  static PRResults fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PRResults._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    // prices is Map<String,TimeSeries>
    prices = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["prices"],
        (value) => TimeSeries.fromJson(value))
  ;
  }
}

/// Create a PRResults sans new, for more declarative construction
PRResults
pRResults([Map<String,TimeSeries> prices]) =>
  new PRResults(prices);

class PRRequest {
  PRRequest(this.dateRange, this.symbols);

  final DateRange dateRange;
  final Set<String> symbols;
  // custom <class PRRequest>
  // end <class PRRequest>
}

/// Create a PRRequest sans new, for more declarative construction
PRRequest
pRRequest([DateRange dateRange,
  Set<String> symbols]) =>
  new PRRequest(dateRange,
      symbols);

// custom <library portfolio>
// end <library portfolio>
main() {
// custom <main>
// end <main>

}
