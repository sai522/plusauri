library plus.models.flow_model;

import 'common.dart';
import 'dart:convert' as convert;
import 'dart:math';
import 'income_statement.dart';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/map_utilities.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/time_series.dart';
import 'package:plus/finance.dart';

// end <additional imports>

final _logger = new Logger('flow_model');

class FlowSpec {
  const FlowSpec(this.descr, this.source, this.cFlowSequenceSpec);

  bool operator==(FlowSpec other) =>
    identical(this, other) ||
    descr == other.descr &&
    source == other.source &&
    cFlowSequenceSpec == other.cFlowSequenceSpec;

  int get hashCode => hash3(descr, source, cFlowSequenceSpec);

  copy() => new FlowSpec._copy(this);
  final String descr;
  final String source;
  final CFlowSequenceSpec cFlowSequenceSpec;
  // custom <class FlowSpec>

  expand(DateRange dr) => cFlowSequenceSpec.expand(dr);

  visitFlows(DateRange onRange, FlowVisitor visitor) =>
      cFlowSequenceSpec.visitFlows(onRange, visitor);

  // end <class FlowSpec>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "descr": ebisu_utils.toJson(descr),
      "source": ebisu_utils.toJson(source),
      "cFlowSequenceSpec": ebisu_utils.toJson(cFlowSequenceSpec),
  };

  static FlowSpec fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FlowSpec._fromJsonMapImpl(json);
  }

  FlowSpec._fromJsonMapImpl(Map jsonMap) :
    descr = jsonMap["descr"],
    source = jsonMap["source"],
    cFlowSequenceSpec = CFlowSequenceSpec.fromJson(jsonMap["cFlowSequenceSpec"]);

  FlowSpec._copy(FlowSpec other) :
    descr = other.descr,
    source = other.source,
    cFlowSequenceSpec = other.cFlowSequenceSpec == null? null : other.cFlowSequenceSpec.copy();

}

class FlowKey {
  const FlowKey(this.name, this.isIncome);

  bool operator==(FlowKey other) =>
    identical(this, other) ||
    name == other.name &&
    isIncome == other.isIncome;

  int get hashCode => hash2(name, isIncome);

  copy() => new FlowKey._copy(this);
  final String name;
  final bool isIncome;
  // custom <class FlowKey>
  // end <class FlowKey>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "name": ebisu_utils.toJson(name),
      "isIncome": ebisu_utils.toJson(isIncome),
  };

  static FlowKey fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FlowKey._fromJsonMapImpl(json);
  }

  FlowKey._fromJsonMapImpl(Map jsonMap) :
    name = jsonMap["name"],
    isIncome = jsonMap["isIncome"];

  FlowKey._copy(FlowKey other) :
    name = other.name,
    isIncome = other.isIncome;

}

/// Key that is either ExpenseType or IncomeType
class FlowTypeKey {
  FlowTypeKey();

  bool operator==(FlowTypeKey other) =>
    identical(this, other) ||
    flowType == other.flowType;

  int get hashCode => flowType.hashCode;

  copy() => new FlowTypeKey()
    ..flowType = flowType;

  String flowType;
  // custom <class FlowTypeKey>
  // end <class FlowTypeKey>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "flowType": ebisu_utils.toJson(flowType),
  };

  static FlowTypeKey fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FlowTypeKey()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    flowType = jsonMap["flowType"];
  }
}

/// Create a FlowTypeKey sans new, for more declarative construction
FlowTypeKey
flowTypeKey() =>
  new FlowTypeKey();

class IncomeSpec {
  const IncomeSpec(this.incomeType, this.flowSpec);

  bool operator==(IncomeSpec other) =>
    identical(this, other) ||
    incomeType == other.incomeType &&
    flowSpec == other.flowSpec;

  int get hashCode => hash2(incomeType, flowSpec);

  copy() => new IncomeSpec._copy(this);
  final IncomeType incomeType;
  final FlowSpec flowSpec;
  // custom <class IncomeSpec>

  IncomeFlows expand(DateRange onRange) =>
      new IncomeFlows(incomeType, flowSpec.expand(onRange));

  visitFlows(DateRange onRange, FlowVisitor visitor) =>
      flowSpec.visitFlows(onRange, visitor);

  // end <class IncomeSpec>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "incomeType": ebisu_utils.toJson(incomeType),
      "flowSpec": ebisu_utils.toJson(flowSpec),
  };

  static IncomeSpec fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new IncomeSpec._fromJsonMapImpl(json);
  }

  IncomeSpec._fromJsonMapImpl(Map jsonMap) :
    incomeType = IncomeType.fromJson(jsonMap["incomeType"]),
    flowSpec = FlowSpec.fromJson(jsonMap["flowSpec"]);

  IncomeSpec._copy(IncomeSpec other) :
    incomeType = other.incomeType == null? null : other.incomeType.copy(),
    flowSpec = other.flowSpec == null? null : other.flowSpec.copy();

}

class ExpenseSpec {
  const ExpenseSpec(this.expenseType, this.flowSpec);

  bool operator==(ExpenseSpec other) =>
    identical(this, other) ||
    expenseType == other.expenseType &&
    flowSpec == other.flowSpec;

  int get hashCode => hash2(expenseType, flowSpec);

  copy() => new ExpenseSpec._copy(this);
  final ExpenseType expenseType;
  final FlowSpec flowSpec;
  // custom <class ExpenseSpec>

  ExpenseFlows expand(DateRange onRange) =>
      new ExpenseFlows(expenseType, flowSpec.expand(onRange));

  visitFlows(DateRange onRange, FlowVisitor visitor) =>
      flowSpec.visitFlows(onRange, visitor);

  // end <class ExpenseSpec>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "expenseType": ebisu_utils.toJson(expenseType),
      "flowSpec": ebisu_utils.toJson(flowSpec),
  };

  static ExpenseSpec fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ExpenseSpec._fromJsonMapImpl(json);
  }

  ExpenseSpec._fromJsonMapImpl(Map jsonMap) :
    expenseType = ExpenseType.fromJson(jsonMap["expenseType"]),
    flowSpec = FlowSpec.fromJson(jsonMap["flowSpec"]);

  ExpenseSpec._copy(ExpenseSpec other) :
    expenseType = other.expenseType == null? null : other.expenseType.copy(),
    flowSpec = other.flowSpec == null? null : other.flowSpec.copy();

}

class FlowModel {
  FlowModel(this.incomeModel, this.expenseModel);

  bool operator==(FlowModel other) =>
    identical(this, other) ||
    const MapEquality().equals(incomeModel, other.incomeModel) &&
    const MapEquality().equals(expenseModel, other.expenseModel);

  int get hashCode => hash2(const MapEquality().hash(incomeModel), const MapEquality().hash(expenseModel));

  copy() => new FlowModel._copy(this);
  final Map<String,IncomeSpec> incomeModel;
  final Map<String,ExpenseSpec> expenseModel;
  // custom <class FlowModel>

  RealizedFlows expand(DateRange dateRange) =>
      new RealizedFlows(
          valueApply(incomeModel, (IncomeSpec spec) => spec.expand(dateRange)),
          valueApply(expenseModel, (ExpenseSpec spec) => spec.expand(dateRange)));

  List<FlowKey> get incomeKeys {
    if (_incomeKeys == null) {
      _incomeKeys =
          new List<FlowKey>.from(incomeModel.keys.map((key) => new FlowKey(key, true)));
    }
    return _incomeKeys;
  }

  List<FlowKey> get expenseKeys {
    if (_expenseKeys == null) {
      _expenseKeys = new List<FlowKey>.from(
          expenseModel.keys.map((key) => new FlowKey(key, false)));
    }
    return _expenseKeys;
  }

  // end <class FlowModel>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "incomeModel": ebisu_utils.toJson(incomeModel),
      "expenseModel": ebisu_utils.toJson(expenseModel),
  };

  static FlowModel fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FlowModel._fromJsonMapImpl(json);
  }

  FlowModel._fromJsonMapImpl(Map jsonMap) :
    // incomeModel is Map<String,IncomeSpec>
    incomeModel = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["incomeModel"],
        (value) => IncomeSpec.fromJson(value)),
    // expenseModel is Map<String,ExpenseSpec>
    expenseModel = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["expenseModel"],
        (value) => ExpenseSpec.fromJson(value));

  FlowModel._copy(FlowModel other) :
    incomeModel = valueApply(other.incomeModel, (v) =>
      v == null? null : v.copy()),
    expenseModel = valueApply(other.expenseModel, (v) =>
      v == null? null : v.copy()),
    _incomeKeys = other._incomeKeys == null? null :
      (new List.from(other._incomeKeys.map((e) =>
        e == null? null : e.copy()))),
    _expenseKeys = other._expenseKeys == null? null :
      (new List.from(other._expenseKeys.map((e) =>
        e == null? null : e.copy())));

  List<FlowKey> _incomeKeys;
  List<FlowKey> _expenseKeys;
}

class IncomeFlows {
  const IncomeFlows(this.incomeType, this.timeSeries);

  bool operator==(IncomeFlows other) =>
    identical(this, other) ||
    incomeType == other.incomeType &&
    timeSeries == other.timeSeries;

  int get hashCode => hash2(incomeType, timeSeries);

  copy() => new IncomeFlows._copy(this);
  final IncomeType incomeType;
  final TimeSeries timeSeries;
  // custom <class IncomeFlows>

  filterOnYear(int year) =>
      new IncomeFlows(
          incomeType,
          new TimeSeries.fromIterable(timeSeries.filterOnYear(year)));

  int get length => timeSeries.length;
  double get sum => timeSeries.sum;
  List<DateValue> get data => timeSeries.data;

  // end <class IncomeFlows>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "incomeType": ebisu_utils.toJson(incomeType),
      "timeSeries": ebisu_utils.toJson(timeSeries),
  };

  static IncomeFlows fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new IncomeFlows._fromJsonMapImpl(json);
  }

  IncomeFlows._fromJsonMapImpl(Map jsonMap) :
    incomeType = IncomeType.fromJson(jsonMap["incomeType"]),
    timeSeries = TimeSeries.fromJson(jsonMap["timeSeries"]);

  IncomeFlows._copy(IncomeFlows other) :
    incomeType = other.incomeType == null? null : other.incomeType.copy(),
    timeSeries = other.timeSeries == null? null : other.timeSeries.copy();

}

class ExpenseFlows {
  const ExpenseFlows(this.expenseType, this.timeSeries);

  bool operator==(ExpenseFlows other) =>
    identical(this, other) ||
    expenseType == other.expenseType &&
    timeSeries == other.timeSeries;

  int get hashCode => hash2(expenseType, timeSeries);

  copy() => new ExpenseFlows._copy(this);
  final ExpenseType expenseType;
  final TimeSeries timeSeries;
  // custom <class ExpenseFlows>

  filterOnYear(int year) =>
      new ExpenseFlows(
          expenseType,
          new TimeSeries.fromIterable(timeSeries.filterOnYear(year)));

  int get length => timeSeries.length;
  double get sum => timeSeries.sum;
  List<DateValue> get data => timeSeries.data;

  // end <class ExpenseFlows>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "expenseType": ebisu_utils.toJson(expenseType),
      "timeSeries": ebisu_utils.toJson(timeSeries),
  };

  static ExpenseFlows fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ExpenseFlows._fromJsonMapImpl(json);
  }

  ExpenseFlows._fromJsonMapImpl(Map jsonMap) :
    expenseType = ExpenseType.fromJson(jsonMap["expenseType"]),
    timeSeries = TimeSeries.fromJson(jsonMap["timeSeries"]);

  ExpenseFlows._copy(ExpenseFlows other) :
    expenseType = other.expenseType == null? null : other.expenseType.copy(),
    timeSeries = other.timeSeries == null? null : other.timeSeries.copy();

}

class RealizedFlows {
  const RealizedFlows(this.incomeFlows, this.expenseFlows);

  bool operator==(RealizedFlows other) =>
    identical(this, other) ||
    const MapEquality().equals(incomeFlows, other.incomeFlows) &&
    const MapEquality().equals(expenseFlows, other.expenseFlows);

  int get hashCode => hash2(const MapEquality().hash(incomeFlows), const MapEquality().hash(expenseFlows));

  copy() => new RealizedFlows._copy(this);
  final Map<String,IncomeFlows> incomeFlows;
  final Map<String,ExpenseFlows> expenseFlows;
  // custom <class RealizedFlows>

  RealizedFlows.courtesy(this.incomeFlows, this.expenseFlows);

  static Map _filteredFlows(Map flowMap, filter(on)) {
    var filteredMap = {};
    flowMap.forEach((k, v) {
      var hits = filter(v);
      if (hits.length > 0) {
        filteredMap[k] = hits;
      }
    });
    return filteredMap;
  }

  int get numFlows => incomeFlows.length + expenseFlows.length;

  double netFlowsOn(Date asOf, {RateCurve incomeCurve,
      RateCurve expenseCurve}) {

    sumFlows(Map<String, TimeSeries> flows, RateCurve curve) {
      double result = 0.0;
      flows.values.forEach((ts) {
        result += (curve != null) ? ts.sumToDateOnCurve(asOf, curve) : ts.sum;
      });
      return result;
    }

    return sumFlows(incomeFlows, incomeCurve) -
        sumFlows(expenseFlows, expenseCurve);
  }

  filterOnYear(int year) =>
      new RealizedFlows.courtesy(
          _filteredFlows(incomeFlows, (IncomeFlows flows) => flows.filterOnYear(year)),
          _filteredFlows(expenseFlows, (ExpenseFlows flows) => flows.filterOnYear(year)));

  toString() =>
      incomeFlows.length > 0 || expenseFlows.length > 0 ?
          ebisu_utils.prettyJsonMap(toJson()) :
          'No Flows';


  // end <class RealizedFlows>

  Map toJson() => {
      "incomeFlows": ebisu_utils.toJson(incomeFlows),
      "expenseFlows": ebisu_utils.toJson(expenseFlows),
  };

  static RealizedFlows fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new RealizedFlows._fromJsonMapImpl(json);
  }

  RealizedFlows._fromJsonMapImpl(Map jsonMap) :
    // incomeFlows is Map<String,IncomeFlows>
    incomeFlows = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["incomeFlows"],
        (value) => IncomeFlows.fromJson(value)),
    // expenseFlows is Map<String,ExpenseFlows>
    expenseFlows = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["expenseFlows"],
        (value) => ExpenseFlows.fromJson(value));

  RealizedFlows._copy(RealizedFlows other) :
    incomeFlows = valueApply(other.incomeFlows, (v) =>
      v == null? null : v.copy()),
    expenseFlows = valueApply(other.expenseFlows, (v) =>
      v == null? null : v.copy());

}

Random _randomJsonGenerator = new Random(0);
// custom <library flow_model>
// end <library flow_model>
