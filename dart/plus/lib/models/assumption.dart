library plus.models.assumption;

import 'common.dart';
import 'dart:convert' as convert;
import 'dart:math';
import 'flow_model.dart';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/map_utilities.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/logging.dart';

// end <additional imports>

final _logger = new Logger('assumption');

class HoldingReturnType implements Comparable<HoldingReturnType> {
  static const INTEREST = const HoldingReturnType._(0);
  static const QUALIFIED_DIVIDEND = const HoldingReturnType._(1);
  static const UNQUALIFIED_DIVIDEND = const HoldingReturnType._(2);
  static const CAPITAL_GAIN_DISTRIBUTION = const HoldingReturnType._(3);
  static const CAPITAL_APPRECIATION = const HoldingReturnType._(4);

  static get values =>
      [
          INTEREST,
          QUALIFIED_DIVIDEND,
          UNQUALIFIED_DIVIDEND,
          CAPITAL_GAIN_DISTRIBUTION,
          CAPITAL_APPRECIATION];

  final int value;

  int get hashCode => value;

  const HoldingReturnType._(this.value);

  copy() => this;

  int compareTo(HoldingReturnType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case INTEREST:
        return "Interest";
      case QUALIFIED_DIVIDEND:
        return "QualifiedDividend";
      case UNQUALIFIED_DIVIDEND:
        return "UnqualifiedDividend";
      case CAPITAL_GAIN_DISTRIBUTION:
        return "CapitalGainDistribution";
      case CAPITAL_APPRECIATION:
        return "CapitalAppreciation";
    }
    return null;
  }

  static HoldingReturnType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "Interest":
        return INTEREST;
      case "QualifiedDividend":
        return QUALIFIED_DIVIDEND;
      case "UnqualifiedDividend":
        return UNQUALIFIED_DIVIDEND;
      case "CapitalGainDistribution":
        return CAPITAL_GAIN_DISTRIBUTION;
      case "CapitalAppreciation":
        return CAPITAL_APPRECIATION;
      default:
        return null;
    }
  }

  int toJson() => value;
  static HoldingReturnType fromJson(int v) {
    return v == null ? null : values[v];
  }

  static String randJson() {
    return values[_randomJsonGenerator.nextInt(5)].toString();
  }

}

class LiquidationSortType implements Comparable<LiquidationSortType> {
  static const SELL_FARTHEST_PARTITION = const LiquidationSortType._(0);
  static const SELL_LARGEST_GAINER = const LiquidationSortType._(1);

  static get values => [SELL_FARTHEST_PARTITION, SELL_LARGEST_GAINER];

  final int value;

  int get hashCode => value;

  const LiquidationSortType._(this.value);

  copy() => this;

  int compareTo(LiquidationSortType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case SELL_FARTHEST_PARTITION:
        return "SellFarthestPartition";
      case SELL_LARGEST_GAINER:
        return "SellLargestGainer";
    }
    return null;
  }

  static LiquidationSortType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "SellFarthestPartition":
        return SELL_FARTHEST_PARTITION;
      case "SellLargestGainer":
        return SELL_LARGEST_GAINER;
      default:
        return null;
    }
  }

  int toJson() => value;
  static LiquidationSortType fromJson(int v) {
    return v == null ? null : values[v];
  }

  static String randJson() {
    return values[_randomJsonGenerator.nextInt(2)].toString();
  }

}

class InvestmentSortType implements Comparable<InvestmentSortType> {
  static const BUY_CLOSEST_PARTITION = const InvestmentSortType._(0);
  static const BUY_LARGEST_LOSER = const InvestmentSortType._(1);

  static get values => [BUY_CLOSEST_PARTITION, BUY_LARGEST_LOSER];

  final int value;

  int get hashCode => value;

  const InvestmentSortType._(this.value);

  copy() => this;

  int compareTo(InvestmentSortType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case BUY_CLOSEST_PARTITION:
        return "BuyClosestPartition";
      case BUY_LARGEST_LOSER:
        return "BuyLargestLoser";
    }
    return null;
  }

  static InvestmentSortType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "BuyClosestPartition":
        return BUY_CLOSEST_PARTITION;
      case "BuyLargestLoser":
        return BUY_LARGEST_LOSER;
      default:
        return null;
    }
  }

  int toJson() => value;
  static InvestmentSortType fromJson(int v) {
    return v == null ? null : values[v];
  }

  static String randJson() {
    return values[_randomJsonGenerator.nextInt(2)].toString();
  }

}

/// Provides (potentially) a blend of returns based on [HoldingReturnType].
class HoldingReturns {
  const HoldingReturns(this.returns);

  bool operator ==(HoldingReturns other) =>
      identical(this, other) || const MapEquality().equals(returns, other.returns);

  int get hashCode => const MapEquality().hash(returns).hashCode;

  copy() => new HoldingReturns._copy(this);
  final Map<HoldingReturnType, RateCurve> returns;
  // custom <class HoldingReturns>

  HoldingReturns adjustReturns(CurveAdjuster curveAdjuster) =>
      new HoldingReturns(
          valueApply(returns, (RateCurve rateCurve) => curveAdjuster(rateCurve)));

  // end <class HoldingReturns>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "returns": ebisu_utils.toJson(returns),
  };

  static HoldingReturns fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new HoldingReturns._fromJsonMapImpl(json);
  }

  HoldingReturns._fromJsonMapImpl(Map jsonMap)
      : // returns is Map<HoldingReturnType,RateCurve>
      returns = ebisu_utils.constructMapFromJsonData(
          jsonMap["returns"],
          (value) => RateCurve.fromJson(value),
          (key) => HoldingReturnType.fromString(key));

  HoldingReturns._copy(HoldingReturns other)
      : returns = valueApply(other.returns, (v) => v == null ? null : v.copy());

}

/// Describes the type of holding (Stock, Bond, ... Blend) and various paritions.
///
class InstrumentAssumptions {
  const InstrumentAssumptions(this.holdingType, this.holdingReturns,
      this.instrumentPartitions);

  bool operator ==(InstrumentAssumptions other) =>
      identical(this, other) ||
          holdingType == other.holdingType &&
              holdingReturns == other.holdingReturns &&
              instrumentPartitions == other.instrumentPartitions;

  int get hashCode => hash3(holdingType, holdingReturns, instrumentPartitions);

  copy() => new InstrumentAssumptions._copy(this);
  final HoldingType holdingType;
  final HoldingReturns holdingReturns;
  final InstrumentPartitions instrumentPartitions;
  // custom <class InstrumentAssumptions>

  InstrumentAssumptions
      adjustHoldingReturnCurves(CurveAdjuster curveAdjuster) =>
      new InstrumentAssumptions(
          holdingType,
          holdingReturns.adjustReturns(curveAdjuster),
          instrumentPartitions);

  /*
  InstrumentAssumptions.fromHoldingType(this.holdingType) {
    // You should not discern partitions from equity, other and blend
    assert(holdingType != HoldingType.BLEND &&
        holdingType != HoldingType.OTHER &&
        holdingType != HoldingType.STOCK);

    switch(holdingType) {
      case HoldingType.BOND:
        return const InstrumentPartitions(
          const AllocationPartition(0.0, 1.0, 0.0, 0.0),
          const InvestmentStylePartition.empty(),
          const CapitalizationPartition.empty());
      case HoldingType.CASH:
        return const InstrumentPartitions(
          const AllocationPartition(0.0, 0.0, 1.0, 0.0),
          const InvestmentStylePartition.empty(),
          const CapitalizationPartition.empty());
      case HoldingType.STOCK:
        _logger.fine('Returning default stock partitions $holdingType');
        return DefaultSingleStockPartitions;
      case HoldingType.OTHER:
        _logger.fine('Returning default other partitions $holdingType');
        return DefaultOtherPartitions;
      case HoldingType.BLEND:
        _logger.fine('Returning default blend partitions $holdingType');
        return DefaultBlendPartitions;
    }
  }
     */
  // end <class InstrumentAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "holdingType": ebisu_utils.toJson(holdingType),
    "holdingReturns": ebisu_utils.toJson(holdingReturns),
    "instrumentPartitions": ebisu_utils.toJson(instrumentPartitions),
  };

  static InstrumentAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new InstrumentAssumptions._fromJsonMapImpl(json);
  }

  InstrumentAssumptions._fromJsonMapImpl(Map jsonMap)
      : holdingType = HoldingType.fromJson(jsonMap["holdingType"]),
        holdingReturns = HoldingReturns.fromJson(jsonMap["holdingReturns"]),
        instrumentPartitions = InstrumentPartitions.fromJson(
          jsonMap["instrumentPartitions"]);

  InstrumentAssumptions._copy(InstrumentAssumptions other)
      : holdingType = other.holdingType == null ?
          null :
          other.holdingType.copy(),
        holdingReturns = other.holdingReturns == null ?
          null :
          other.holdingReturns.copy(),
        instrumentPartitions = other.instrumentPartitions == null ?
          null :
          other.instrumentPartitions.copy();

}

class ReserveAssumptions {
  const ReserveAssumptions(this.excess, this.shortfall);

  bool operator ==(ReserveAssumptions other) =>
      identical(this, other) ||
          excess == other.excess && shortfall == other.shortfall;

  int get hashCode => hash2(excess, shortfall);

  copy() => new ReserveAssumptions._copy(this);
  final RateCurve excess;
  final RateCurve shortfall;
  // custom <class ReserveAssumptions>
  // end <class ReserveAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "excess": ebisu_utils.toJson(excess),
    "shortfall": ebisu_utils.toJson(shortfall),
  };

  static ReserveAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ReserveAssumptions._fromJsonMapImpl(json);
  }

  ReserveAssumptions._fromJsonMapImpl(Map jsonMap)
      : excess = RateCurve.fromJson(jsonMap["excess"]),
        shortfall = RateCurve.fromJson(jsonMap["shortfall"]);

  ReserveAssumptions._copy(ReserveAssumptions other)
      : excess = other.excess == null ? null : other.excess.copy(),
        shortfall = other.shortfall == null ? null : other.shortfall.copy();

}

class ReinvestmentPolicy {
  const ReinvestmentPolicy(this.dividendsReinvested, this.interestReinvested);

  bool operator ==(ReinvestmentPolicy other) =>
      identical(this, other) ||
          dividendsReinvested == other.dividendsReinvested &&
              interestReinvested == other.interestReinvested;

  int get hashCode => hash2(dividendsReinvested, interestReinvested);

  copy() => new ReinvestmentPolicy._copy(this);
  final bool dividendsReinvested;
  final bool interestReinvested;
  // custom <class ReinvestmentPolicy>
  // end <class ReinvestmentPolicy>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "dividendsReinvested": ebisu_utils.toJson(dividendsReinvested),
    "interestReinvested": ebisu_utils.toJson(interestReinvested),
  };

  static ReinvestmentPolicy fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ReinvestmentPolicy._fromJsonMapImpl(json);
  }

  ReinvestmentPolicy._fromJsonMapImpl(Map jsonMap)
      : dividendsReinvested = jsonMap["dividendsReinvested"],
        interestReinvested = jsonMap["interestReinvested"];

  ReinvestmentPolicy._copy(ReinvestmentPolicy other)
      : dividendsReinvested = other.dividendsReinvested,
        interestReinvested = other.interestReinvested;

}

class DateAssumptions {
  DateAssumptions();

  bool operator ==(DateAssumptions other) =>
      identical(this, other) ||
          deathDate == other.deathDate && retirementDate == other.retirementDate;

  int get hashCode => hash2(deathDate, retirementDate);

  copy() => new DateAssumptions()
      ..deathDate = deathDate
      ..retirementDate = retirementDate;

  Date deathDate;
  Date retirementDate;
  // custom <class DateAssumptions>
  // end <class DateAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "deathDate": ebisu_utils.toJson(deathDate),
    "retirementDate": ebisu_utils.toJson(retirementDate),
  };

  static DateAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new DateAssumptions().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    deathDate = Date.fromJson(jsonMap["deathDate"]);
    retirementDate = Date.fromJson(jsonMap["retirementDate"]);
  }
}

/// Create a DateAssumptions sans new, for more declarative construction
DateAssumptions dateAssumptions() => new DateAssumptions();

class AccountAssumptions {
  const AccountAssumptions(this.otherInstrumentAssumptions,
      this.defaultReinvestmentPolicy, this.holdingReinvestmentPolicies);

  bool operator ==(AccountAssumptions other) =>
      identical(this, other) ||
          otherInstrumentAssumptions == other.otherInstrumentAssumptions &&
              defaultReinvestmentPolicy == other.defaultReinvestmentPolicy &&
              const MapEquality().equals(
                  holdingReinvestmentPolicies,
                  other.holdingReinvestmentPolicies);

  int get hashCode =>
      hash3(
          otherInstrumentAssumptions,
          defaultReinvestmentPolicy,
          const MapEquality().hash(holdingReinvestmentPolicies));

  copy() => new AccountAssumptions._copy(this);
  final InstrumentAssumptions otherInstrumentAssumptions;
  final ReinvestmentPolicy defaultReinvestmentPolicy;
  final Map<String, ReinvestmentPolicy> holdingReinvestmentPolicies;
  // custom <class AccountAssumptions>

  ReinvestmentPolicy getReinvestmentPolicy(String holdingName) {

    if (holdingReinvestmentPolicies != null) {
      final result = holdingReinvestmentPolicies[holdingName];
      if (result != null) {
        return result;
      }
    }

    if (defaultReinvestmentPolicy != null) return defaultReinvestmentPolicy;

    return ReinvestForGrowth;
  }

  AccountAssumptions copyWithCurveAdjustment(CurveAdjuster curveAdjuster) {
    var copy = otherInstrumentAssumptions;
    if (copy != null) {
      copy = copy.adjustHoldingReturnCurves(curveAdjuster);
    }
    return new AccountAssumptions(
        copy,
        defaultReinvestmentPolicy,
        holdingReinvestmentPolicies);
  }

  // end <class AccountAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "otherInstrumentAssumptions": ebisu_utils.toJson(
        otherInstrumentAssumptions),
    "defaultReinvestmentPolicy": ebisu_utils.toJson(defaultReinvestmentPolicy),
    "holdingReinvestmentPolicies": ebisu_utils.toJson(
        holdingReinvestmentPolicies),
  };

  static AccountAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new AccountAssumptions._fromJsonMapImpl(json);
  }

  AccountAssumptions._fromJsonMapImpl(Map jsonMap)
      : otherInstrumentAssumptions = InstrumentAssumptions.fromJson(
          jsonMap["otherInstrumentAssumptions"]),
        defaultReinvestmentPolicy = ReinvestmentPolicy.fromJson(
          jsonMap["defaultReinvestmentPolicy"]),
        // holdingReinvestmentPolicies is Map<String,ReinvestmentPolicy>
      holdingReinvestmentPolicies = ebisu_utils.constructMapFromJsonData(
          jsonMap["holdingReinvestmentPolicies"],
          (value) => ReinvestmentPolicy.fromJson(value));

  AccountAssumptions._copy(AccountAssumptions other)
      : otherInstrumentAssumptions = other.otherInstrumentAssumptions == null ?
          null :
          other.otherInstrumentAssumptions.copy(),
        defaultReinvestmentPolicy = other.defaultReinvestmentPolicy == null ?
          null :
          other.defaultReinvestmentPolicy.copy(),
        holdingReinvestmentPolicies = valueApply(
          other.holdingReinvestmentPolicies,
          (v) => v == null ? null : v.copy());

}

class BalanceSheetAssumptions {
  const BalanceSheetAssumptions(this.assetAssumptions,
      this.liabilityAssumptions, this.accountAssumptions, this.instrumentAssumptions);

  bool operator ==(BalanceSheetAssumptions other) =>
      identical(this, other) ||
          const MapEquality().equals(assetAssumptions, other.assetAssumptions) &&
              const MapEquality().equals(liabilityAssumptions, other.liabilityAssumptions) &&
              const MapEquality().equals(accountAssumptions, other.accountAssumptions) &&
              const MapEquality().equals(instrumentAssumptions, other.instrumentAssumptions);

  int get hashCode =>
      hash4(
          const MapEquality().hash(assetAssumptions),
          const MapEquality().hash(liabilityAssumptions),
          const MapEquality().hash(accountAssumptions),
          const MapEquality().hash(instrumentAssumptions));

  copy() => new BalanceSheetAssumptions._copy(this);
  final Map<String, RateCurve> assetAssumptions;
  final Map<String, RateCurve> liabilityAssumptions;
  final Map<String, AccountAssumptions> accountAssumptions;
  final Map<String, InstrumentAssumptions> instrumentAssumptions;
  // custom <class BalanceSheetAssumptions>

  RateCurve assetAssumption(String key) {
    var result = assetAssumptions[key];
    return result == null ? ZeroRateCurve : result;
  }

  RateCurve liabilityAssumption(String key) {
    var result = liabilityAssumptions[key];
    return result == null ? ZeroRateCurve : result;
  }

  HoldingReturns getHoldingReturns(HoldingKey holdingKey) =>
      _getInstrumentAssumptions(holdingKey).holdingReturns;

  InstrumentPartitions getInstrumentPartitions(HoldingKey holdingKey) =>
      _getInstrumentAssumptions(holdingKey).instrumentPartitions;

  ReinvestmentPolicy getReinvestmentPolicy(HoldingKey holdingKey) {
    final userSpecified = accountAssumptions[holdingKey.accountName];
    return userSpecified == null ?
        DefaultAccountAssumptions.defaultReinvestmentPolicy :
        userSpecified.getReinvestmentPolicy(holdingKey.holdingName);
  }

  InstrumentAssumptions _getRealInstrumentAssumptions(String holdingName) {
    assert(holdingName != GeneralAccount);
    return instrumentAssumptions[holdingName];
  }

  InstrumentAssumptions _getAccountInstrumentAssumptions(String accountName) {
    final assumptions = accountAssumptions[accountName];
    return (assumptions != null) ?
        assumptions.otherInstrumentAssumptions :
        null;
  }

  InstrumentAssumptions _getInstrumentAssumptions(HoldingKey holdingKey) {
    InstrumentAssumptions result;

    if (holdingKey.holdingName != GeneralAccount) result =
        _getRealInstrumentAssumptions(holdingKey.holdingName);

    if (result == null) result =
        _getAccountInstrumentAssumptions(holdingKey.accountName);

    if (result == null) result = DefaultAccountInstrumentAssumptions;

    return result;
  }

  // end <class BalanceSheetAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "assetAssumptions": ebisu_utils.toJson(assetAssumptions),
    "liabilityAssumptions": ebisu_utils.toJson(liabilityAssumptions),
    "accountAssumptions": ebisu_utils.toJson(accountAssumptions),
    "instrumentAssumptions": ebisu_utils.toJson(instrumentAssumptions),
  };

  static BalanceSheetAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new BalanceSheetAssumptions._fromJsonMapImpl(json);
  }

  BalanceSheetAssumptions._fromJsonMapImpl(Map jsonMap)
      : // assetAssumptions is Map<String,RateCurve>
      assetAssumptions = ebisu_utils.constructMapFromJsonData(
          jsonMap["assetAssumptions"],
          (value) => RateCurve.fromJson(value)),
        // liabilityAssumptions is Map<String,RateCurve>
      liabilityAssumptions = ebisu_utils.constructMapFromJsonData(
          jsonMap["liabilityAssumptions"],
          (value) => RateCurve.fromJson(value)),
        // accountAssumptions is Map<String,AccountAssumptions>
      accountAssumptions = ebisu_utils.constructMapFromJsonData(
          jsonMap["accountAssumptions"],
          (value) => AccountAssumptions.fromJson(value)),
        // instrumentAssumptions is Map<String,InstrumentAssumptions>
      instrumentAssumptions = ebisu_utils.constructMapFromJsonData(
          jsonMap["instrumentAssumptions"],
          (value) => InstrumentAssumptions.fromJson(value));

  BalanceSheetAssumptions._copy(BalanceSheetAssumptions other)
      : assetAssumptions = valueApply(
          other.assetAssumptions,
          (v) => v == null ? null : v.copy()),
        liabilityAssumptions = valueApply(
          other.liabilityAssumptions,
          (v) => v == null ? null : v.copy()),
        accountAssumptions = valueApply(
          other.accountAssumptions,
          (v) => v == null ? null : v.copy()),
        instrumentAssumptions = valueApply(
          other.instrumentAssumptions,
          (v) => v == null ? null : v.copy());

}

class BalanceSheetAssumptionsBuilder {
  BalanceSheetAssumptionsBuilder();

  Map<String, RateCurve> assetAssumptions = {};
  Map<String, RateCurve> liabilityAssumptions = {};
  Map<String, AccountAssumptions> accountAssumptions = {};
  Map<String, InstrumentAssumptions> instrumentAssumptions = {};
  // custom <class BalanceSheetAssumptionsBuilder>
  // end <class BalanceSheetAssumptionsBuilder>
  BalanceSheetAssumptions buildInstance() =>
      new BalanceSheetAssumptions(
          assetAssumptions,
          liabilityAssumptions,
          accountAssumptions,
          instrumentAssumptions);

  factory BalanceSheetAssumptionsBuilder.copyFrom(BalanceSheetAssumptions _) =>
      new BalanceSheetAssumptionsBuilder._copyImpl(_.copy());

  BalanceSheetAssumptionsBuilder._copyImpl(BalanceSheetAssumptions _)
      : assetAssumptions = _.assetAssumptions,
        liabilityAssumptions = _.liabilityAssumptions,
        accountAssumptions = _.accountAssumptions,
        instrumentAssumptions = _.instrumentAssumptions;


}

/// Create a BalanceSheetAssumptionsBuilder sans new, for more declarative construction
BalanceSheetAssumptionsBuilder balanceSheetAssumptionsBuilder() =>
    new BalanceSheetAssumptionsBuilder();


class StrategyAssumptions {
  StrategyAssumptions();

  bool operator ==(StrategyAssumptions other) =>
      identical(this, other) ||
          targetPartitions == other.targetPartitions &&
              emergencyReserves == other.emergencyReserves &&
              liquidationSortType == other.liquidationSortType &&
              investmentSortType == other.investmentSortType;

  int get hashCode =>
      hash4(
          targetPartitions,
          emergencyReserves,
          liquidationSortType,
          investmentSortType);

  copy() => new StrategyAssumptions()
      ..targetPartitions =
          targetPartitions == null ? null : targetPartitions.copy()
      ..emergencyReserves = emergencyReserves
      ..liquidationSortType =
          liquidationSortType == null ? null : liquidationSortType.copy()
      ..investmentSortType =
          investmentSortType == null ? null : investmentSortType.copy();

  InstrumentPartitions targetPartitions;
  /// Desired amount to keep in reserves before investing any excesses
  num emergencyReserves = 0.0;
  LiquidationSortType liquidationSortType;
  InvestmentSortType investmentSortType;
  // custom <class StrategyAssumptions>
  // end <class StrategyAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "targetPartitions": ebisu_utils.toJson(targetPartitions),
    "emergencyReserves": ebisu_utils.toJson(emergencyReserves),
    "liquidationSortType": ebisu_utils.toJson(liquidationSortType),
    "investmentSortType": ebisu_utils.toJson(investmentSortType),
  };

  static StrategyAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new StrategyAssumptions().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    targetPartitions =
        InstrumentPartitions.fromJson(jsonMap["targetPartitions"]);
    emergencyReserves = jsonMap["emergencyReserves"];
    liquidationSortType =
        LiquidationSortType.fromJson(jsonMap["liquidationSortType"]);
    investmentSortType =
        InvestmentSortType.fromJson(jsonMap["investmentSortType"]);
  }
}

/// Create a StrategyAssumptions sans new, for more declarative construction
StrategyAssumptions strategyAssumptions() => new StrategyAssumptions();

class TaxRateAssumptions {
  const TaxRateAssumptions(this.pensionIncome, this.socialSecurityIncome,
      this.capitalGains, this.dividends, this.rentalIncome, this.ordinaryIncome);

  bool operator ==(TaxRateAssumptions other) =>
      identical(this, other) ||
          pensionIncome == other.pensionIncome &&
              socialSecurityIncome == other.socialSecurityIncome &&
              capitalGains == other.capitalGains &&
              dividends == other.dividends &&
              rentalIncome == other.rentalIncome &&
              ordinaryIncome == other.ordinaryIncome;

  int get hashCode =>
      hashObjects(
          [
              pensionIncome,
              socialSecurityIncome,
              capitalGains,
              dividends,
              rentalIncome,
              ordinaryIncome]);

  copy() => new TaxRateAssumptions._copy(this);
  final RateCurve pensionIncome;
  final RateCurve socialSecurityIncome;
  final RateCurve capitalGains;
  final RateCurve dividends;
  final RateCurve rentalIncome;
  final RateCurve ordinaryIncome;
  // custom <class TaxRateAssumptions>
  // end <class TaxRateAssumptions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "pensionIncome": ebisu_utils.toJson(pensionIncome),
    "socialSecurityIncome": ebisu_utils.toJson(socialSecurityIncome),
    "capitalGains": ebisu_utils.toJson(capitalGains),
    "dividends": ebisu_utils.toJson(dividends),
    "rentalIncome": ebisu_utils.toJson(rentalIncome),
    "ordinaryIncome": ebisu_utils.toJson(ordinaryIncome),
  };

  static TaxRateAssumptions fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new TaxRateAssumptions._fromJsonMapImpl(json);
  }

  TaxRateAssumptions._fromJsonMapImpl(Map jsonMap)
      : pensionIncome = RateCurve.fromJson(jsonMap["pensionIncome"]),
        socialSecurityIncome = RateCurve.fromJson(
          jsonMap["socialSecurityIncome"]),
        capitalGains = RateCurve.fromJson(jsonMap["capitalGains"]),
        dividends = RateCurve.fromJson(jsonMap["dividends"]),
        rentalIncome = RateCurve.fromJson(jsonMap["rentalIncome"]),
        ordinaryIncome = RateCurve.fromJson(jsonMap["ordinaryIncome"]);

  TaxRateAssumptions._copy(TaxRateAssumptions other)
      : pensionIncome = other.pensionIncome == null ?
          null :
          other.pensionIncome.copy(),
        socialSecurityIncome = other.socialSecurityIncome == null ?
          null :
          other.socialSecurityIncome.copy(),
        capitalGains = other.capitalGains == null ?
          null :
          other.capitalGains.copy(),
        dividends = other.dividends == null ? null : other.dividends.copy(),
        rentalIncome = other.rentalIncome == null ?
          null :
          other.rentalIncome.copy(),
        ordinaryIncome = other.ordinaryIncome == null ?
          null :
          other.ordinaryIncome.copy();

}

class AssumptionModel {
  AssumptionModel(this.inflation, this.balanceSheetAssumptions,
      this.incomeModelOverrides, this.expenseModelOverrides, this.dateAssumptions,
      this.strategyAssumptions, this.taxRateAssumptions, this.reserveAssumptions) {
    _init();
  }

  bool operator ==(AssumptionModel other) =>
      identical(this, other) ||
          inflation == other.inflation &&
              balanceSheetAssumptions == other.balanceSheetAssumptions &&
              const MapEquality().equals(incomeModelOverrides, other.incomeModelOverrides) &&
              const MapEquality().equals(
                  expenseModelOverrides,
                  other.expenseModelOverrides) &&
              const MapEquality().equals(dateAssumptions, other.dateAssumptions) &&
              strategyAssumptions == other.strategyAssumptions &&
              taxRateAssumptions == other.taxRateAssumptions &&
              reserveAssumptions == other.reserveAssumptions;

  int get hashCode =>
      hashObjects(
          [
              inflation,
              balanceSheetAssumptions,
              const MapEquality().hash(incomeModelOverrides),
              const MapEquality().hash(expenseModelOverrides),
              const MapEquality().hash(dateAssumptions),
              strategyAssumptions,
              taxRateAssumptions,
              reserveAssumptions]);

  copy() => new AssumptionModel._copy(this);
  final RateCurve inflation;
  final BalanceSheetAssumptions balanceSheetAssumptions;
  final Map<String, IncomeSpec> incomeModelOverrides;
  final Map<String, ExpenseSpec> expenseModelOverrides;
  final Map<String, DateAssumptions> dateAssumptions;
  final StrategyAssumptions strategyAssumptions;
  final TaxRateAssumptions taxRateAssumptions;
  final ReserveAssumptions reserveAssumptions;
  // custom <class AssumptionModel>

  InstrumentPartitions get targetPartitions =>
      strategyAssumptions.targetPartitions;

  void _init() {
    assert(taxRateAssumptions != null);
  }

  // end <class AssumptionModel>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
    "inflation": ebisu_utils.toJson(inflation),
    "balanceSheetAssumptions": ebisu_utils.toJson(balanceSheetAssumptions),
    "incomeModelOverrides": ebisu_utils.toJson(incomeModelOverrides),
    "expenseModelOverrides": ebisu_utils.toJson(expenseModelOverrides),
    "dateAssumptions": ebisu_utils.toJson(dateAssumptions),
    "strategyAssumptions": ebisu_utils.toJson(strategyAssumptions),
    "taxRateAssumptions": ebisu_utils.toJson(taxRateAssumptions),
    "reserveAssumptions": ebisu_utils.toJson(reserveAssumptions),
  };

  static AssumptionModel fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new AssumptionModel._fromJsonMapImpl(json);
  }

  AssumptionModel._fromJsonMapImpl(Map jsonMap)
      : inflation = RateCurve.fromJson(jsonMap["inflation"]),
        balanceSheetAssumptions = BalanceSheetAssumptions.fromJson(
          jsonMap["balanceSheetAssumptions"]),
        // incomeModelOverrides is Map<String,IncomeSpec>
      incomeModelOverrides = ebisu_utils.constructMapFromJsonData(
          jsonMap["incomeModelOverrides"],
          (value) => IncomeSpec.fromJson(value)),
        // expenseModelOverrides is Map<String,ExpenseSpec>
      expenseModelOverrides = ebisu_utils.constructMapFromJsonData(
          jsonMap["expenseModelOverrides"],
          (value) => ExpenseSpec.fromJson(value)),
        // dateAssumptions is Map<String,DateAssumptions>
      dateAssumptions = ebisu_utils.constructMapFromJsonData(
          jsonMap["dateAssumptions"],
          (value) => DateAssumptions.fromJson(value)),
        strategyAssumptions = StrategyAssumptions.fromJson(
          jsonMap["strategyAssumptions"]),
        taxRateAssumptions = TaxRateAssumptions.fromJson(
          jsonMap["taxRateAssumptions"]),
        reserveAssumptions = ReserveAssumptions.fromJson(
          jsonMap["reserveAssumptions"]);

  AssumptionModel._copy(AssumptionModel other)
      : inflation = other.inflation == null ? null : other.inflation.copy(),
        balanceSheetAssumptions = other.balanceSheetAssumptions == null ?
          null :
          other.balanceSheetAssumptions.copy(),
        incomeModelOverrides = valueApply(
          other.incomeModelOverrides,
          (v) => v == null ? null : v.copy()),
        expenseModelOverrides = valueApply(
          other.expenseModelOverrides,
          (v) => v == null ? null : v.copy()),
        dateAssumptions = valueApply(
          other.dateAssumptions,
          (v) => v == null ? null : v.copy()),
        strategyAssumptions = other.strategyAssumptions == null ?
          null :
          other.strategyAssumptions.copy(),
        taxRateAssumptions = other.taxRateAssumptions == null ?
          null :
          other.taxRateAssumptions.copy(),
        reserveAssumptions = other.reserveAssumptions == null ?
          null :
          other.reserveAssumptions.copy();

}

class AssumptionModelBuilder {
  AssumptionModelBuilder();

  RateCurve inflation;
  BalanceSheetAssumptions balanceSheetAssumptions;
  Map<String, IncomeSpec> incomeModelOverrides = {};
  Map<String, ExpenseSpec> expenseModelOverrides = {};
  Map<String, DateAssumptions> dateAssumptions = {};
  StrategyAssumptions strategyAssumptions;
  TaxRateAssumptions taxRateAssumptions;
  ReserveAssumptions reserveAssumptions;
  // custom <class AssumptionModelBuilder>
  // end <class AssumptionModelBuilder>
  AssumptionModel buildInstance() =>
      new AssumptionModel(
          inflation,
          balanceSheetAssumptions,
          incomeModelOverrides,
          expenseModelOverrides,
          dateAssumptions,
          strategyAssumptions,
          taxRateAssumptions,
          reserveAssumptions);

  factory AssumptionModelBuilder.copyFrom(AssumptionModel _) =>
      new AssumptionModelBuilder._copyImpl(_.copy());

  AssumptionModelBuilder._copyImpl(AssumptionModel _)
      : inflation = _.inflation,
        balanceSheetAssumptions = _.balanceSheetAssumptions,
        incomeModelOverrides = _.incomeModelOverrides,
        expenseModelOverrides = _.expenseModelOverrides,
        dateAssumptions = _.dateAssumptions,
        strategyAssumptions = _.strategyAssumptions,
        taxRateAssumptions = _.taxRateAssumptions,
        reserveAssumptions = _.reserveAssumptions;


}

/// Create a AssumptionModelBuilder sans new, for more declarative construction
AssumptionModelBuilder assumptionModelBuilder() => new AssumptionModelBuilder();


Random _randomJsonGenerator = new Random(0);
// custom <library assumption>

final ZeroGrowthBalanceSheetAssumptions =
    const BalanceSheetAssumptions(const {}, const {}, const {}, const {});

final ZeroHoldingReturns = const HoldingReturns(const {});

final DefaultReserveAssumptions = new ReserveAssumptions(
    rateCurve([dateValue(date(1900, 1, 1), 0.0075)]),
    rateCurve([dateValue(date(1900, 1, 1), 0.02)]));

const ReinvestForGrowth = const ReinvestmentPolicy(true, true);

const ReinvestForCashFlow = const ReinvestmentPolicy(false, false);

final DefaultSingleStockPartitions = const InstrumentPartitions(
    const AllocationPartition(1.0, 0.0, 0.0, 0.0),
    const InvestmentStylePartition(1.0, 0.0, 0.0),
    const CapitalizationPartition(0.0, 0.0, 1.0));

final DefaultOtherPartitions = const InstrumentPartitions(
    const AllocationPartition(0.0, 0.0, 0.0, 1.0),
    const InvestmentStylePartition.empty(),
    const CapitalizationPartition.empty());

final DefaultBlendPartitions = const InstrumentPartitions(
    const AllocationPartition(0.34, 0.33, 0.33, 0.0),
    const InvestmentStylePartition(0.34, 0.33, 0.33),
    const CapitalizationPartition(0.34, 0.33, 0.33));

final DefaultTargetPartitions = const InstrumentPartitions(
    const AllocationPartition(0.6, 0.3, 0.1, 0.0),
    const InvestmentStylePartition(0.3, 0.3, 0.4),
    const CapitalizationPartition(0.3, 0.4, 0.3));

final DefaultHoldingReturns = new HoldingReturns({
  HoldingReturnType.INTEREST: rateCurve([dateValue(date(1900, 1, 1), 0.0075)])
});

final DefaultAccountInstrumentAssumptions = new InstrumentAssumptions(
    HoldingType.BLEND,
    DefaultHoldingReturns,
    DefaultTargetPartitions);

final DefaultAccountAssumptions = new AccountAssumptions(
    DefaultAccountInstrumentAssumptions,
    ReinvestForGrowth,
    const {});

final DefaultStrategyAssumptions = new StrategyAssumptions()
    ..targetPartitions = DefaultTargetPartitions
    ..emergencyReserves = 30000.0
    ..liquidationSortType = LiquidationSortType.SELL_FARTHEST_PARTITION
    ..investmentSortType = InvestmentSortType.BUY_CLOSEST_PARTITION;

FlowModel overrideFlowModel(FlowModel original, AssumptionModel assumptionModel)
    {
  FlowModel result = original;
  final incomeOverrides = assumptionModel.incomeModelOverrides;
  final expenseOverrides = assumptionModel.expenseModelOverrides;
  if (incomeOverrides.length > 0 || expenseOverrides.length > 0) {
    result = result.copy();
    incomeOverrides.keys.forEach((k) => result.incomeModel[k] =
        incomeOverrides[k]);
    expenseOverrides.keys.forEach((k) => result.expenseModel[k] =
        expenseOverrides[k]);
  }
  return result;
}

final DefaultPensionIncomeTaxRate =
    rateCurve([dateValue(date(1900, 1, 1), 0.15)]);
final DefaultSocialSecurityTaxRate =
    rateCurve([dateValue(date(1900, 1, 1), 0.15)]);
final DefaultDividendsTaxRate = rateCurve([dateValue(date(1900, 1, 1), 0.20)]);
final DefaultCapitalGainsTaxRate =
    rateCurve([dateValue(date(1900, 1, 1), 0.20)]);
final DefaultRentalIncomeTaxRate =
    rateCurve([dateValue(date(1900, 1, 1), 0.20)]);
final DefaultOrdinaryIncomeTaxRate =
    rateCurve([dateValue(date(1900, 1, 1), 0.25)]);

final DefaultTaxRateAssumptions = new TaxRateAssumptions(
    DefaultPensionIncomeTaxRate,
    DefaultSocialSecurityTaxRate,
    DefaultCapitalGainsTaxRate,
    DefaultDividendsTaxRate,
    DefaultRentalIncomeTaxRate,
    DefaultOrdinaryIncomeTaxRate);

main() {

  print(ebisu_utils.prettyJsonMap(ZeroHoldingReturns));
  print(ebisu_utils.prettyJsonMap(ZeroGrowthBalanceSheetAssumptions));

}

// end <library assumption>

