library plus.models.liquidation_summary;

import 'common.dart';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/map_utilities.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

import 'package:plus/date.dart';
import 'package:plus/models/income_statement.dart';
import 'package:plus/models/flow_model.dart';

// end <additional imports>

final _logger = new Logger('liquidation_summary');

/// Allows income/expense flows to be comingled by time
class FlowDetail
  implements Comparable<FlowDetail> {
  FlowDetail(this.date, this.type, this.flow, this.name);

  bool operator==(FlowDetail other) =>
    identical(this, other) ||
    date == other.date &&
    type == other.type &&
    flow == other.flow &&
    name == other.name;

  int get hashCode => hash4(date,
    type,
    flow,
    name);

  copy() => new FlowDetail._copy(this);
  final Date date;
  final int type;
  final double flow;
  final String name;
  // custom <class FlowDetail>

  int compareTo(FlowDetail other) {
    int result = 0;
    ((result = date.compareTo(other.date)) == 0) &&
    ((result = (flow > 0.0 && flow < 0.0) ? -1 :
       (flow < 0.0 && flow > 0.0) ? 1 : 0) == 0) &&
    ((result = name.compareTo(other.name)) == 0) &&
    ((result = flow.compareTo(other.flow)) == 0);
    return result;
  }

  bool get isIncome => flow > 0.0;

  get flowType => flow < 0? ExpenseType.fromJson(type) :
      IncomeType.fromJson(type);

  FlowKey get flowKey => _flowKey == null?
    (_flowKey = new FlowKey(name, isIncome)) : _flowKey;

  toString() => 'Flow ($date, $flowType, $name, $flow)';

  // end <class FlowDetail>

  Map toJson() => {
      "date": ebisu_utils.toJson(date),
      "type": ebisu_utils.toJson(type),
      "flow": ebisu_utils.toJson(flow),
      "name": ebisu_utils.toJson(name),
  };

  static FlowDetail fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FlowDetail._fromJsonMapImpl(json);
  }

  FlowDetail._fromJsonMapImpl(Map jsonMap) :
    date = Date.fromJson(jsonMap["date"]),
    type = jsonMap["type"],
    flow = jsonMap["flow"],
    name = jsonMap["name"];

  FlowDetail._copy(FlowDetail other) :
    date = other.date,
    type = other.type,
    flow = other.flow,
    name = other.name,
    _flowKey = other._flowKey == null? null : other._flowKey.copy();

  FlowKey _flowKey;
}

/// Documents an adjustment to a holding/asset to fund/invest
class FundingAdjustment {
  const FundingAdjustment(this.flowDetail, this.holdingKey, this.amount,
    this.endBalance, this.flowRemaining);

  bool operator==(FundingAdjustment other) =>
    identical(this, other) ||
    flowDetail == other.flowDetail &&
    holdingKey == other.holdingKey &&
    amount == other.amount &&
    endBalance == other.endBalance &&
    flowRemaining == other.flowRemaining;

  int get hashCode => hashObjects([
    flowDetail,
    holdingKey,
    amount,
    endBalance,
    flowRemaining]);

  copy() => new FundingAdjustment._copy(this);
  final FlowDetail flowDetail;
  final HoldingKey holdingKey;
  /// Amount added/subtracted to the account
  final double amount;
  final double endBalance;
  final double flowRemaining;
  // custom <class FundingAdjustment>

  bool isValid() =>
    endBalance >= 0.0 &&
    ((amount >= 0.0 && flowRemaining >= 0.0) ||
        (amount <= 0.0 && flowRemaining <= 0.0));

  // end <class FundingAdjustment>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "flowDetail": ebisu_utils.toJson(flowDetail),
      "holdingKey": ebisu_utils.toJson(holdingKey),
      "amount": ebisu_utils.toJson(amount),
      "endBalance": ebisu_utils.toJson(endBalance),
      "flowRemaining": ebisu_utils.toJson(flowRemaining),
  };

  static FundingAdjustment fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FundingAdjustment._fromJsonMapImpl(json);
  }

  FundingAdjustment._fromJsonMapImpl(Map jsonMap) :
    flowDetail = FlowDetail.fromJson(jsonMap["flowDetail"]),
    holdingKey = HoldingKey.fromJson(jsonMap["holdingKey"]),
    amount = jsonMap["amount"],
    endBalance = jsonMap["endBalance"],
    flowRemaining = jsonMap["flowRemaining"];

  FundingAdjustment._copy(FundingAdjustment other) :
    flowDetail = other.flowDetail == null? null : other.flowDetail.copy(),
    holdingKey = other.holdingKey == null? null : other.holdingKey.copy(),
    amount = other.amount,
    endBalance = other.endBalance,
    flowRemaining = other.flowRemaining;

}

class FlowEntry {
  const FlowEntry(this.flowDetail, this.fundingAdjustments);

  bool operator==(FlowEntry other) =>
    identical(this, other) ||
    flowDetail == other.flowDetail &&
    const ListEquality().equals(fundingAdjustments, other.fundingAdjustments);

  int get hashCode => hash2(flowDetail, const ListEquality<FundingAdjustment>().hash(fundingAdjustments));

  copy() => new FlowEntry._copy(this);
  final FlowDetail flowDetail;
  final List<FundingAdjustment> fundingAdjustments;
  // custom <class FlowEntry>

  double get flow => flowDetail.flow;
  String get name => flowDetail.name;

  // end <class FlowEntry>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "flowDetail": ebisu_utils.toJson(flowDetail),
      "fundingAdjustments": ebisu_utils.toJson(fundingAdjustments),
  };

  static FlowEntry fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new FlowEntry._fromJsonMapImpl(json);
  }

  FlowEntry._fromJsonMapImpl(Map jsonMap) :
    flowDetail = FlowDetail.fromJson(jsonMap["flowDetail"]),
    // fundingAdjustments is List<FundingAdjustment>
    fundingAdjustments = ebisu_utils
      .constructListFromJsonData(jsonMap["fundingAdjustments"],
                                 (data) => FundingAdjustment.fromJson(data));

  FlowEntry._copy(FlowEntry other) :
    flowDetail = other.flowDetail == null? null : other.flowDetail.copy(),
    fundingAdjustments = other.fundingAdjustments == null? null :
      (new List.from(other.fundingAdjustments.map((e) =>
        e == null? null : e.copy())));

}

class FlowEntryBuilder {
  FlowEntryBuilder();

  FlowDetail flowDetail;
  List<FundingAdjustment> fundingAdjustments = [];
  // custom <class FlowEntryBuilder>

  bool get isIncome => flowDetail.isIncome;

  void addAdjustment(FundingAdjustment adjustment) {
    fundingAdjustments.add(adjustment);
  }

  get expenseDetail {
    assert(!flowDetail.isIncome);
    return flowDetail;
  }

  get incomeDetail {
    assert(flowDetail.isIncome);
    return flowDetail;
  }

  double get flowRemaining => fundingAdjustments.length > 0?
    fundingAdjustments.last.flowRemaining :
    flowDetail.flow;

  bool get hasFlowRemaining =>
    isIncome? flowRemaining > MinimumFlowResidual :
    flowRemaining < -MinimumFlowResidual;

  toString() => 'FEB($flowDetail, $fundingAdjustments)';

  // end <class FlowEntryBuilder>
  FlowEntry buildInstance() => new FlowEntry(
    flowDetail, fundingAdjustments);

  factory FlowEntryBuilder.copyFrom(FlowEntry _) =>
    new FlowEntryBuilder._copyImpl(_.copy());

  FlowEntryBuilder._copyImpl(FlowEntry _) :
    flowDetail = _.flowDetail,
    fundingAdjustments = _.fundingAdjustments;


}

/// Create a FlowEntryBuilder sans new, for more declarative construction
FlowEntryBuilder
flowEntryBuilder() =>
  new FlowEntryBuilder();


class LiquidationSummary {
  const LiquidationSummary(this.flowEntries);

  bool operator==(LiquidationSummary other) =>
    identical(this, other) ||
    const ListEquality().equals(flowEntries, other.flowEntries);

  int get hashCode => const ListEquality<FlowEntry>().hash(flowEntries).hashCode;

  copy() => new LiquidationSummary._copy(this);
  final List<FlowEntry> flowEntries;
  // custom <class LiquidationSummary>
  // end <class LiquidationSummary>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "flowEntries": ebisu_utils.toJson(flowEntries),
  };

  static LiquidationSummary fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new LiquidationSummary._fromJsonMapImpl(json);
  }

  LiquidationSummary._fromJsonMapImpl(Map jsonMap) :
    // flowEntries is List<FlowEntry>
    flowEntries = ebisu_utils
      .constructListFromJsonData(jsonMap["flowEntries"],
                                 (data) => FlowEntry.fromJson(data));

  LiquidationSummary._copy(LiquidationSummary other) :
    flowEntries = other.flowEntries == null? null :
      (new List.from(other.flowEntries.map((e) =>
        e == null? null : e.copy())));

}

Random _randomJsonGenerator = new Random(0);
// custom <library liquidation_summary>

const MinimumFlowResidual = 0.0001;

// end <library liquidation_summary>
