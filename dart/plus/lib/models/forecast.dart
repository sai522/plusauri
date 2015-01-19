library plus.models.forecast;

import 'balance_sheet.dart';
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
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/finance.dart';

// end <additional imports>

final _logger = new Logger('forecast');

/// Tracks dividends by type - irrespective of reinvestment policy
///
class DistributionBreakdown {
  DistributionBreakdown(this.qualified, this.unqualified,
    this.capitalGainDistribution, this.interest);

  bool operator==(DistributionBreakdown other) =>
    identical(this, other) ||
    qualified == other.qualified &&
    unqualified == other.unqualified &&
    capitalGainDistribution == other.capitalGainDistribution &&
    interest == other.interest;

  int get hashCode => hash4(qualified,
    unqualified,
    capitalGainDistribution,
    interest);

  copy() => new DistributionBreakdown._copy(this);
  num qualified = 0.0;
  num unqualified = 0.0;
  num capitalGainDistribution = 0.0;
  num interest = 0.0;
  // custom <class DistributionBreakdown>

  DistributionBreakdown.empty();

  DistributionBreakdown operator +(DistributionBreakdown other) {
    return new DistributionBreakdown(qualified + other.qualified,
        unqualified + other.unqualified,
        capitalGainDistribution + other.capitalGainDistribution,
        interest + other.interest);
  }

  DistributionBreakdown operator -(DistributionBreakdown other) =>
    new DistributionBreakdown(qualified - other.qualified,
        unqualified - other.unqualified,
        capitalGainDistribution - other.capitalGainDistribution,
        interest - other.interest);

  DistributionBreakdown operator -() =>
    new DistributionBreakdown(-qualified, -unqualified, -capitalGainDistribution,
                              -interest);

  void plusEqual(DistributionBreakdown other) {
    qualified += other.qualified;
    unqualified += other.unqualified;
    capitalGainDistribution += other.capitalGainDistribution;
    interest += other.interest;
  }

  num get total => qualified + unqualified + capitalGainDistribution + interest;

  // end <class DistributionBreakdown>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "qualified": ebisu_utils.toJson(qualified),
      "unqualified": ebisu_utils.toJson(unqualified),
      "capitalGainDistribution": ebisu_utils.toJson(capitalGainDistribution),
      "interest": ebisu_utils.toJson(interest),
  };

  static DistributionBreakdown fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new DistributionBreakdown._fromJsonMapImpl(json);
  }

  DistributionBreakdown._fromJsonMapImpl(Map jsonMap) :
    qualified = jsonMap["qualified"],
    unqualified = jsonMap["unqualified"],
    capitalGainDistribution = jsonMap["capitalGainDistribution"],
    interest = jsonMap["interest"];

  DistributionBreakdown._copy(DistributionBreakdown other) :
    qualified = other.qualified,
    unqualified = other.unqualified,
    capitalGainDistribution = other.capitalGainDistribution,
    interest = other.interest;

}

/// Create a DistributionBreakdown sans new, for more declarative construction
DistributionBreakdown
distributionBreakdown([num qualified,
  num unqualified,
  num capitalGainDistribution,
  num interest]) =>
  new DistributionBreakdown(qualified,
      unqualified,
      capitalGainDistribution,
      interest);

/// Track distributions by those that are reinvested vs those that are distributed.
///
class DistributionSummary {
  DistributionSummary(this.distributed, this.reinvested);

  bool operator==(DistributionSummary other) =>
    identical(this, other) ||
    distributed == other.distributed &&
    reinvested == other.reinvested;

  int get hashCode => hash2(distributed, reinvested);

  copy() => new DistributionSummary._copy(this);
  DistributionBreakdown distributed;
  DistributionBreakdown reinvested;
  // custom <class DistributionSummary>

  DistributionSummary.empty() :
    distributed = new DistributionBreakdown.empty(),
    reinvested = new DistributionBreakdown.empty();

  double get totalDividends => distributed.total + reinvested.total;
  double get totalInterest => distributed.interest + reinvested.interest;
  double get totalQualified => distributed.qualified + reinvested.qualified;
  double get totalUnqualified =>
    distributed.unqualified + reinvested.unqualified;
  double get totalCapitalGainDistribution =>
    distributed.capitalGainDistribution + reinvested.capitalGainDistribution;
  double get distributions => distributed.total;


  DistributionSummary operator +(DistributionSummary other) =>
    new DistributionSummary(distributed + other.distributed,
        reinvested + other.reinvested);

  DistributionSummary operator -(DistributionSummary other) =>
    new DistributionSummary(distributed - other.distributed,
        reinvested - other.reinvested);

  DistributionSummary operator -() =>
    new DistributionSummary(-distributed, - reinvested);

  void plusEqual(DistributionSummary other) {
    distributed.plusEqual(other.distributed);
    reinvested.plusEqual(other.reinvested);
  }

  // end <class DistributionSummary>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "distributed": ebisu_utils.toJson(distributed),
      "reinvested": ebisu_utils.toJson(reinvested),
  };

  static DistributionSummary fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new DistributionSummary._fromJsonMapImpl(json);
  }

  DistributionSummary._fromJsonMapImpl(Map jsonMap) :
    distributed = DistributionBreakdown.fromJson(jsonMap["distributed"]),
    reinvested = DistributionBreakdown.fromJson(jsonMap["reinvested"]);

  DistributionSummary._copy(DistributionSummary other) :
    distributed = other.distributed == null? null : other.distributed.copy(),
    reinvested = other.reinvested == null? null : other.reinvested.copy();

}

/// Create a DistributionSummary sans new, for more declarative construction
DistributionSummary
distributionSummary([DistributionBreakdown distributed,
  DistributionBreakdown reinvested]) =>
  new DistributionSummary(distributed,
      reinvested);

/// Balance at endpoints of a given period
class PeriodBalance {
  PeriodBalance();

  bool operator==(PeriodBalance other) =>
    identical(this, other) ||
    start == other.start &&
    end == other.end;

  int get hashCode => hash2(start, end);

  copy() => new PeriodBalance()
    ..start = start == null? null : start.copy()
    ..end = end == null? null : end.copy();

  DateValue start;
  DateValue end;
  // custom <class PeriodBalance>

  PeriodBalance.empty(int year) {
    final fr = fiscalRange(year);
    start = dateValue(fr.start, 0.0);
    end = dateValue(fr.end, 0.0);
  }

  PeriodBalance.courtesy(this.start, this.end);

  bool get isEmpty => start.value == 0.0 && end.value == 0.0;

  PeriodBalance operator +(PeriodBalance other) => new PeriodBalance.courtesy(
      dv(minDate(start.date, other.start.date), start.value + other.start.value), dv(
      maxDate(end.date, other.end.date), end.value + other.end.value));

  PeriodBalance operator -(PeriodBalance other) => new PeriodBalance.courtesy(
      dv(minDate(start.date, other.start.date), start.value - other.start.value), dv(
      maxDate(end.date, other.end.date), end.value - other.end.value));

  PeriodBalance operator -() => copy()
      ..start = -start
      ..end = -end;

  double get ccReturn {
    double numYears = years(start.date, end.date);
    return log(end.value / start.value) / numYears;
  }

  double get startValue => start.value;
  Date get startDate => start.date;
  double get endValue => end.value;
  Date get endDate => end.date;

  // end <class PeriodBalance>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "start": ebisu_utils.toJson(start),
      "end": ebisu_utils.toJson(end),
  };

  static PeriodBalance fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PeriodBalance()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    start = DateValue.fromJson(jsonMap["start"]);
    end = DateValue.fromJson(jsonMap["end"]);
  }
}

/// Create a PeriodBalance sans new, for more declarative construction
PeriodBalance
periodBalance() =>
  new PeriodBalance();

/// Collection of the most prominant partitions.
/// Can be applied to instrument valuations as well as accounts, synthetics, etc.
///
class InstrumentPartitionMappings {
  InstrumentPartitionMappings();

  bool operator==(InstrumentPartitionMappings other) =>
    identical(this, other) ||
    allocation == other.allocation &&
    style == other.style &&
    capitalization == other.capitalization;

  int get hashCode => hash3(allocation, style, capitalization);

  copy() => new InstrumentPartitionMappings()
    ..allocation = allocation == null? null : allocation.copy()
    ..style = style == null? null : style.copy()
    ..capitalization = capitalization == null? null : capitalization.copy();

  PartitionMapping allocation;
  PartitionMapping style;
  PartitionMapping capitalization;
  // custom <class InstrumentPartitionMappings>

  InstrumentPartitionMappings.courtesy(this.allocation, this.style, this.capitalization);

  InstrumentPartitionMappings.empty()
      : allocation = const PartitionMapping.empty(),
        style = const PartitionMapping.empty(),
        capitalization = const PartitionMapping.empty();

  InstrumentPartitionMappings.fromMissingAssumptions(double value)
      : allocation = new PartitionMapping.validated(0.0, value, const {}),
        style = new PartitionMapping.validated(0.0, value, const {}),
        capitalization = new PartitionMapping.validated(0.0, value, const {});

  InstrumentPartitionMappings.fromAssumptions(double value, InstrumentPartitions
      instrumentPartitions)
      : allocation = new PartitionMapping.validated(value, 0.0,
          instrumentPartitions.allocationPartition.partitionMap),
        style = new PartitionMapping.validated(value, 0.0,
          instrumentPartitions.investmentStylePartition.partitionMap),
        capitalization = new PartitionMapping.validated(value, 0.0,
          instrumentPartitions.capitalizationPartition.partitionMap);

  InstrumentPartitionMappings newValue(double value) {
    assert(isValid);
    final partitioned = allocation.partitioned;
    final unpartitioned = allocation.unpartitioned;
    final total = partitioned + unpartitioned;
    if (value == 0.0 || total == 0.0) {
      return new InstrumentPartitionMappings.courtesy(
          new PartitionMapping.validated(0.0, value, const {}),
          new PartitionMapping.validated(0.0, value, const {}),
          new PartitionMapping.validated(0.0, value, const {}));
    }

    final partitionedPct = partitioned / total;
    final unpartitionedPct = unpartitioned / total;

    final newPartitioned = partitionedPct * value;
    final newUnpartioned = unpartitionedPct * value;

    assert((1.0 - partitionedPct - unpartitionedPct).abs() < 0.0001);
    assert((value - newPartitioned - newUnpartioned).abs() < 0.0001);

    newPartitionMapping(PartitionMapping oldMapping) =>
        new PartitionMapping.validated(newPartitioned, newUnpartioned,
        oldMapping.partitionMap);

    return new InstrumentPartitionMappings.courtesy(newPartitionMapping(
        allocation), newPartitionMapping(style), newPartitionMapping(capitalization));
  }

  double get totalValue {
    assert(isValid);
    return allocation.total;
  }

  InstrumentPartitionMappings operator +(InstrumentPartitionMappings other) =>
      new InstrumentPartitionMappings.courtesy(allocation + other.allocation, style +
      other.style, capitalization + other.capitalization);

  InstrumentPartitionMappings operator -() =>
      new InstrumentPartitionMappings.courtesy(-allocation, -style, -capitalization);

  InstrumentPartitionMappings operator -(InstrumentPartitionMappings other) =>
      this + (-other);

  bool get isValid => (allocation.total == style.total) && (style.total ==
      capitalization.total);

  // end <class InstrumentPartitionMappings>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "allocation": ebisu_utils.toJson(allocation),
      "style": ebisu_utils.toJson(style),
      "capitalization": ebisu_utils.toJson(capitalization),
  };

  static InstrumentPartitionMappings fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new InstrumentPartitionMappings()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    allocation = PartitionMapping.fromJson(jsonMap["allocation"]);
    style = PartitionMapping.fromJson(jsonMap["style"]);
    capitalization = PartitionMapping.fromJson(jsonMap["capitalization"]);
  }
}

/// Create a InstrumentPartitionMappings sans new, for more declarative construction
InstrumentPartitionMappings
instrumentPartitionMappings() =>
  new InstrumentPartitionMappings();

/// Balance at endpoints of a given period plus additional dividend and balance change breakdown details
class HoldingPeriodBalance {
  const HoldingPeriodBalance(this.holdingType, this.periodBalance,
    this.distributionSummary, this.costBasis, this.capitalGain,
    this.endValuePartitions, this.growthDetails, this.soldInvested);

  bool operator==(HoldingPeriodBalance other) =>
    identical(this, other) ||
    holdingType == other.holdingType &&
    periodBalance == other.periodBalance &&
    distributionSummary == other.distributionSummary &&
    costBasis == other.costBasis &&
    capitalGain == other.capitalGain &&
    endValuePartitions == other.endValuePartitions &&
    const MapEquality().equals(growthDetails, other.growthDetails) &&
    soldInvested == other.soldInvested;

  int get hashCode => hashObjects([
    holdingType,
    periodBalance,
    distributionSummary,
    costBasis,
    capitalGain,
    endValuePartitions,
    const MapEquality().hash(growthDetails),
    soldInvested]);

  copy() => new HoldingPeriodBalance._copy(this);
  final HoldingType holdingType;
  final PeriodBalance periodBalance;
  final DistributionSummary distributionSummary;
  final PeriodBalance costBasis;
  final double capitalGain;
  final InstrumentPartitionMappings endValuePartitions;
  /// Details on modeled growth from start to end - (does *not* including sales/investments)
  final Map<HoldingReturnType,num> growthDetails;
  /// Value sold/invested into over the period
  final double soldInvested;
  // custom <class HoldingPeriodBalance>

  PeriodBalance get totalAssetValue => periodBalance.copy();
  double get totalReturn => endValue - soldInvested - startValue;

  double growthContribution(HoldingReturnType hrt) => growthDetails.containsKey(
      hrt) ? growthDetails[hrt] : 0.0;

  double get interest => growthContribution(
      HoldingReturnType.INTEREST);

  double get capitalAppreciation => growthContribution(
      HoldingReturnType.CAPITAL_APPRECIATION);

  double get totalQualifiedDividends => distributionSummary.totalQualified;
  double get totalUnqualifiedDividends => distributionSummary.totalUnqualified;
  double get totalCapitalGainDistribution => distributionSummary.totalCapitalGainDistribution;
  double get totalInterest => distributionSummary.totalInterest;

  double get qualifiedDistributions => distributionSummary.distributed.qualified;
  double get unqualifiedDistributions => distributionSummary.distributed.unqualified;
  double get capitalGainDistributions => distributionSummary.distributed.capitalGainDistribution;
  double get interestDistributions => distributionSummary.distributed.interest;

  double get qualifiedReinvested => distributionSummary.reinvested.qualified;
  double get unqualifiedReinvested => distributionSummary.reinvested.unqualified;
  double get capitalGainReinvested => distributionSummary.reinvested.capitalGainDistribution;
  double get interestReinvested => distributionSummary.reinvested.interest;

  double get totalDividends => distributionSummary.totalDividends;
  double get distributions => distributionSummary.distributions;

  int get year => periodBalance.end.date.year - 1;
  DateValue get start => periodBalance.start;
  Date get startDate => periodBalance.startDate;
  DateValue get end => periodBalance.end;
  Date get endDate => periodBalance.endDate;

  Date get fiscalPeriodStartDate => fiscalRange(endDate.year - 1).start;

  double get startValue => periodBalance.startValue;
  // value *including* distributions
  double get endValue => periodBalance.endValue +
      distributionSummary.distributions;
  double get endBalance => periodBalance.endValue;
  bool get hasBalance => hasMinimumBalanceCheck(endBalance);

  Map<HoldingReturnType,num>
    _mergeGrowthDetails(HoldingPeriodBalance other) {
    final thisStartValue = startValue;
    final otherStartValue = other.startValue;
    if(thisStartValue == 0.0) {
      assert(growthDetails.values.every((num val) => val == 0.0));
      return other.growthDetails;
    } else if(otherStartValue == 0.0) {
      assert(other.growthDetails.values.every((num val) => val == 0.0));
      return growthDetails;
    }
    return mergeMaps(growthDetails, other.growthDetails);
  }

  HoldingPeriodBalance operator +(HoldingPeriodBalance other) {
    final result = new HoldingPeriodBalance(mergeHoldingTypes(holdingType,
        other.holdingType), periodBalance + other.periodBalance, distributionSummary +
        other.distributionSummary,
        costBasis + other.costBasis,
        capitalGain + other.capitalGain,
        endValuePartitions + other.endValuePartitions,
        _mergeGrowthDetails(other),
        soldInvested + other.soldInvested);

    assert((result.endValuePartitions.totalValue -
        result.periodBalance.end.value).abs() < 0.0001);

    return result;
  }

  /* TODO: evaluate whether subtraction is worthwhile/useful
     It becomes questionable now that InstrumentPartitions are included
     because the subtraction of period balances could lead to 0 totals and
     therefore NaN or invalid partitions
  */

  HoldingPeriodBalance operator -(HoldingPeriodBalance other) =>
      new HoldingPeriodBalance(mergeHoldingTypes(holdingType, other.holdingType),
          periodBalance - other.periodBalance, distributionSummary - other.distributionSummary,
          costBasis - other.costBasis,
          capitalGain - other.capitalGain,
          endValuePartitions - other.endValuePartitions,
          mergeMaps(growthDetails, valueApply(other.growthDetails, (v) => -v)),
          soldInvested - other.soldInvested);

  HoldingPeriodBalance operator -() => new HoldingPeriodBalance(holdingType,
      -periodBalance, -distributionSummary, -costBasis,
      -capitalGain, -endValuePartitions, (valueApply(
            growthDetails, (v) => -v)), -soldInvested);

  // end <class HoldingPeriodBalance>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "holdingType": ebisu_utils.toJson(holdingType),
      "periodBalance": ebisu_utils.toJson(periodBalance),
      "distributionSummary": ebisu_utils.toJson(distributionSummary),
      "costBasis": ebisu_utils.toJson(costBasis),
      "capitalGain": ebisu_utils.toJson(capitalGain),
      "endValuePartitions": ebisu_utils.toJson(endValuePartitions),
      "growthDetails": ebisu_utils.toJson(growthDetails),
      "soldInvested": ebisu_utils.toJson(soldInvested),
  };

  static HoldingPeriodBalance fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new HoldingPeriodBalance._fromJsonMapImpl(json);
  }

  HoldingPeriodBalance._fromJsonMapImpl(Map jsonMap) :
    holdingType = HoldingType.fromJson(jsonMap["holdingType"]),
    periodBalance = PeriodBalance.fromJson(jsonMap["periodBalance"]),
    distributionSummary = DistributionSummary.fromJson(jsonMap["distributionSummary"]),
    costBasis = PeriodBalance.fromJson(jsonMap["costBasis"]),
    capitalGain = jsonMap["capitalGain"],
    endValuePartitions = InstrumentPartitionMappings.fromJson(jsonMap["endValuePartitions"]),
    // growthDetails is Map<HoldingReturnType,num>
    growthDetails = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["growthDetails"],
        (value) => value,
        (key) => HoldingReturnType.fromString(key)),
    soldInvested = jsonMap["soldInvested"];

  HoldingPeriodBalance._copy(HoldingPeriodBalance other) :
    holdingType = other.holdingType == null? null : other.holdingType.copy(),
    periodBalance = other.periodBalance == null? null : other.periodBalance.copy(),
    distributionSummary = other.distributionSummary == null? null : other.distributionSummary.copy(),
    costBasis = other.costBasis == null? null : other.costBasis.copy(),
    capitalGain = other.capitalGain,
    endValuePartitions = other.endValuePartitions == null? null : other.endValuePartitions.copy(),
    growthDetails = valueApply(other.growthDetails, (v) =>
      v),
    soldInvested = other.soldInvested;

}

class TaxAssessment {
  TaxAssessment();

  bool operator==(TaxAssessment other) =>
    identical(this, other) ||
    taxingAuthority == other.taxingAuthority &&
    const MapEquality().equals(taxBases, other.taxBases) &&
    taxBill == other.taxBill;

  int get hashCode => hash3(taxingAuthority, const MapEquality().hash(taxBases), taxBill);

  copy() => new TaxAssessment()
    ..taxingAuthority = taxingAuthority == null? null : taxingAuthority.copy()
    ..taxBases = valueApply(taxBases, (v) =>
    v)
    ..taxBill = taxBill;

  TaxingAuthority taxingAuthority;
  Map<TaxCategory,num> taxBases = {};
  num taxBill = 0.0;
  // custom <class TaxAssessment>
  // end <class TaxAssessment>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "taxingAuthority": ebisu_utils.toJson(taxingAuthority),
      "taxBases": ebisu_utils.toJson(taxBases),
      "taxBill": ebisu_utils.toJson(taxBill),
  };

  static TaxAssessment fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new TaxAssessment()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    taxingAuthority = TaxingAuthority.fromJson(jsonMap["taxingAuthority"]);
    // taxBases is Map<TaxCategory,num>
    taxBases = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["taxBases"],
        (value) => value,
        (key) => TaxCategory.fromString(key))
    ;
    taxBill = jsonMap["taxBill"];
  }
}

/// Create a TaxAssessment sans new, for more declarative construction
TaxAssessment
taxAssessment() =>
  new TaxAssessment();

Random _randomJsonGenerator = new Random(0);
// custom <library forecast>

PeriodBalance sumPeriodBalances(int year, Iterable<PeriodBalance> iterable) =>
    iterable.fold(new PeriodBalance.empty(year), (PeriodBalance prev, PeriodBalance
    pb) => prev + pb);


const MinimumAccountBalance = 0.01;

bool hasMinimumBalanceCheck(double balance) {
  assert(balance >= 0.0);
  return balance >= MinimumAccountBalance;
}

typedef void HPBVisitor(AccountType accountType,
    String symbol, HoldingPeriodBalance hpb);

typedef void AccountVisitor(String account, AccountType accountType,
    String symbol, HoldingPeriodBalance hpb);

// end <library forecast>
