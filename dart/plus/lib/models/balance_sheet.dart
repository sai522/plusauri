library plus.models.balance_sheet;

import 'common.dart';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/map_utilities.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

import 'dart:collection';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';

//import 'package:plus/models/assumption.dart';

// end <additional imports>

final _logger = new Logger('balance_sheet');

///
/// The holding for a given symbol (or a sythetic aggregate as in an account other_holdings).
///
/// Both quantity and unitValue have dates associated with them. The marketValue of
/// the holding is based on the latest date of the two. This date can be different
/// (most likely older) than the date associated with the BalanceSheet owning the
/// holding.
class Holding {
  const Holding(
      this.holdingType, this.quantity, this.unitValue, this.costBasis);

  bool operator ==(Holding other) => identical(this, other) ||
      holdingType == other.holdingType &&
          quantity == other.quantity &&
          unitValue == other.unitValue &&
          costBasis == other.costBasis;

  int get hashCode => hash4(holdingType, quantity, unitValue, costBasis);

  copy() => new Holding._copy(this);
  final HoldingType holdingType;
  final DateValue quantity;
  final DateValue unitValue;
  final double costBasis;
  // custom <class Holding>

  DateValue get marketValue => new DateValue(
      maxDate(quantity.date, unitValue.date), quantity.value * unitValue.value);

  // end <class Holding>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';

  Map toJson() => {
    "holdingType": ebisu_utils.toJson(holdingType),
    "quantity": ebisu_utils.toJson(quantity),
    "unitValue": ebisu_utils.toJson(unitValue),
    "costBasis": ebisu_utils.toJson(costBasis),
  };

  static Holding fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Holding._fromJsonMapImpl(json);
  }

  Holding._fromJsonMapImpl(Map jsonMap)
      : holdingType = HoldingType.fromJson(jsonMap["holdingType"]),
        quantity = DateValue.fromJson(jsonMap["quantity"]),
        unitValue = DateValue.fromJson(jsonMap["unitValue"]),
        costBasis = jsonMap["costBasis"];

  Holding._copy(Holding other)
      : holdingType = other.holdingType == null
          ? null
          : other.holdingType.copy(),
        quantity = other.quantity == null ? null : other.quantity.copy(),
        unitValue = other.unitValue == null ? null : other.unitValue.copy(),
        costBasis = other.costBasis;
}

/// The map of holdings indexed by symbol (or similar name unique to the portfolio).
///
class PortfolioAccount {
  const PortfolioAccount(this.accountType, this.descr, this.owner,
      this.holdingMap, this.otherHoldings);

  bool operator ==(PortfolioAccount other) => identical(this, other) ||
      accountType == other.accountType &&
          descr == other.descr &&
          owner == other.owner &&
          const MapEquality().equals(holdingMap, other.holdingMap) &&
          otherHoldings == other.otherHoldings;

  int get hashCode => hashObjects([
    accountType,
    descr,
    owner,
    const MapEquality().hash(holdingMap),
    otherHoldings
  ]);

  copy() => new PortfolioAccount._copy(this);
  final AccountType accountType;
  final String descr;
  final String owner;
  final Map<String, Holding> holdingMap;
  /// Market value of all account holdings not specified in the holding map.
  ///
  /// This gives the ability to enter an account with a market value and specific tax
  /// treatment without having to fully specify all holdings individually.
  final Holding otherHoldings;
  // custom <class PortfolioAccount>

  Holding holding(String holdingName) =>
      holdingName == GeneralAccount ? otherHoldings : holdingMap[holdingName];

  bool get isDistributionSheltered => isSheltered(accountType);

  bool get canCapitalGainBeSheltered => isSheltered(accountType);

  bool get hasExpenseRestrictions =>
      accountType == AccountType.COLLEGE_IRS529 ||
          accountType == AccountType.HEALTH_SAVINGS_ACCOUNT;

  bool get hasAgeRestrictions => accountType == AccountType.ROTH_IRS401K ||
      accountType == AccountType.TRADITIONAL_IRS401K ||
      accountType == AccountType.TRADITIONAL_IRS401K;

  get holdingType {
    var aggregate;
    if (holdingMap.length > 0) {
      aggregate = holdingMap.values
          .map((holding) => holding.holdingType)
          .reduce((value, elm) => mergeHoldingTypes(value, elm));

      // TODO: Check the logic which initializes when null encountered
      return (otherHoldings != null)
          ? mergeHoldingTypes(aggregate, otherHoldings.holdingType == null
              ? HoldingType.BLEND
              : otherHoldings.holdingType)
          : aggregate;
    }

    return otherHoldings.holdingType;
  }

  _visitHoldings(String account, HoldingVisitor visitor) {
    visitor(account, GeneralAccount, otherHoldings);
    holdingMap.forEach(
        (String symbol, Holding holding) => visitor(account, symbol, holding));
  }

  // end <class PortfolioAccount>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';

  Map toJson() => {
    "accountType": ebisu_utils.toJson(accountType),
    "descr": ebisu_utils.toJson(descr),
    "owner": ebisu_utils.toJson(owner),
    "holdingMap": ebisu_utils.toJson(holdingMap),
    "otherHoldings": ebisu_utils.toJson(otherHoldings),
  };

  static PortfolioAccount fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PortfolioAccount._fromJsonMapImpl(json);
  }

  PortfolioAccount._fromJsonMapImpl(Map jsonMap)
      : accountType = AccountType.fromJson(jsonMap["accountType"]),
        descr = jsonMap["descr"],
        owner = jsonMap["owner"],
        // holdingMap is Map<String,Holding>
        holdingMap = ebisu_utils.constructMapFromJsonData(
            jsonMap["holdingMap"], (value) => Holding.fromJson(value)),
        otherHoldings = Holding.fromJson(jsonMap["otherHoldings"]);

  PortfolioAccount._copy(PortfolioAccount other)
      : accountType = other.accountType == null
          ? null
          : other.accountType.copy(),
        descr = other.descr,
        owner = other.owner,
        holdingMap = valueApply(
            other.holdingMap, (v) => v == null ? null : v.copy()),
        otherHoldings = other.otherHoldings == null
            ? null
            : other.otherHoldings.copy();
}

class PortfolioAccountBuilder {
  PortfolioAccountBuilder();

  AccountType accountType;
  String descr;
  String owner;
  Map<String, Holding> holdingMap = {};
  Holding otherHoldings;
  // custom <class PortfolioAccountBuilder>
  // end <class PortfolioAccountBuilder>
  PortfolioAccount buildInstance() => new PortfolioAccount(
      accountType, descr, owner, holdingMap, otherHoldings);

  factory PortfolioAccountBuilder.copyFrom(PortfolioAccount _) =>
      new PortfolioAccountBuilder._copyImpl(_.copy());

  PortfolioAccountBuilder._copyImpl(PortfolioAccount _)
      : accountType = _.accountType,
        descr = _.descr,
        owner = _.owner,
        holdingMap = _.holdingMap,
        otherHoldings = _.otherHoldings;
}

/// Create a PortfolioAccountBuilder sans new, for more declarative construction
PortfolioAccountBuilder portfolioAccountBuilder() =>
    new PortfolioAccountBuilder();

/// A balance sheet item (i.d. data common to Assets and Liabilities)
class BSItem {
  BSItem();

  bool operator ==(BSItem other) => identical(this, other) ||
      acquired == other.acquired &&
          retired == other.retired &&
          descr == other.descr &&
          owner == other.owner &&
          currentValue == other.currentValue;

  int get hashCode =>
      hashObjects([acquired, retired, descr, owner, currentValue]);

  copy() => new BSItem()
    ..acquired = acquired == null ? null : acquired.copy()
    ..retired = retired == null ? null : retired.copy()
    ..descr = descr
    ..owner = owner
    ..currentValue = currentValue == null ? null : currentValue.copy();

  DateValue acquired;
  DateValue retired;
  String descr;
  String owner;
  DateValue currentValue;
  // custom <class BSItem>

  /**
   * Return the most appropriate marketValue for the asOf
   *
   * If either [currentValue] or [acquired] is null, return the other.
   * Otherwise, return the value closest in time to asOf.
   *
   */
  DateValue marketValue(Date asOf) {
    var result = (currentValue == null)
        ? acquired
        : (acquired == null)
            ? currentValue
            : (asOf.difference(acquired.date).inMicroseconds.abs() >
                    asOf.difference(currentValue.date).inMicroseconds.abs()
                ? currentValue
                : acquired);

    return result != null ? result.copy() : result;
  }

  // end <class BSItem>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';

  Map toJson() => {
    "acquired": ebisu_utils.toJson(acquired),
    "retired": ebisu_utils.toJson(retired),
    "descr": ebisu_utils.toJson(descr),
    "owner": ebisu_utils.toJson(owner),
    "currentValue": ebisu_utils.toJson(currentValue),
  };

  static BSItem fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new BSItem().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    acquired = DateValue.fromJson(jsonMap["acquired"]);
    retired = DateValue.fromJson(jsonMap["retired"]);
    descr = jsonMap["descr"];
    owner = jsonMap["owner"];
    currentValue = DateValue.fromJson(jsonMap["currentValue"]);
  }
}

/// Create a BSItem sans new, for more declarative construction
BSItem bSItem() => new BSItem();

class Asset {
  Asset();

  bool operator ==(Asset other) => identical(this, other) ||
      assetType == other.assetType && bSItem == other.bSItem;

  int get hashCode => hash2(assetType, bSItem);

  copy() => new Asset()
    ..assetType = assetType == null ? null : assetType.copy()
    ..bSItem = bSItem == null ? null : bSItem.copy();

  AssetType assetType;
  BSItem bSItem;
  // custom <class Asset>

  DateValue marketValue(Date date) => bSItem.marketValue(date);

  // end <class Asset>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';

  Map toJson() => {
    "assetType": ebisu_utils.toJson(assetType),
    "bSItem": ebisu_utils.toJson(bSItem),
  };

  static Asset fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Asset().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    assetType = AssetType.fromJson(jsonMap["assetType"]);
    bSItem = BSItem.fromJson(jsonMap["bSItem"]);
  }
}

/// Create a Asset sans new, for more declarative construction
Asset asset() => new Asset();

class Liability {
  Liability();

  bool operator ==(Liability other) => identical(this, other) ||
      liabilityType == other.liabilityType && bSItem == other.bSItem;

  int get hashCode => hash2(liabilityType, bSItem);

  copy() => new Liability()
    ..liabilityType = liabilityType == null ? null : liabilityType.copy()
    ..bSItem = bSItem == null ? null : bSItem.copy();

  LiabilityType liabilityType;
  BSItem bSItem;
  // custom <class Liability>

  DateValue marketValue(Date date) => bSItem.marketValue(date);

  // end <class Liability>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';

  Map toJson() => {
    "liabilityType": ebisu_utils.toJson(liabilityType),
    "bSItem": ebisu_utils.toJson(bSItem),
  };

  static Liability fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Liability().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    liabilityType = LiabilityType.fromJson(jsonMap["liabilityType"]);
    bSItem = BSItem.fromJson(jsonMap["bSItem"]);
  }
}

/// Create a Liability sans new, for more declarative construction
Liability liability() => new Liability();

class BalanceSheet {
  BalanceSheet(
      this.asOf, this.assetMap, this.liabilityMap, this.portfolioAccountMap);

  bool operator ==(BalanceSheet other) => identical(this, other) ||
      asOf == other.asOf &&
          const MapEquality().equals(assetMap, other.assetMap) &&
          const MapEquality().equals(liabilityMap, other.liabilityMap) &&
          const MapEquality().equals(
              portfolioAccountMap, other.portfolioAccountMap);

  int get hashCode => hash4(asOf, const MapEquality().hash(assetMap),
      const MapEquality().hash(liabilityMap),
      const MapEquality().hash(portfolioAccountMap));

  copy() => new BalanceSheet._copy(this);
  final Date asOf;
  final Map<String, Asset> assetMap;
  final Map<String, Liability> liabilityMap;
  final Map<String, PortfolioAccount> portfolioAccountMap;
  // custom <class BalanceSheet>

  Asset asset(String id) => assetMap[id];
  Liability liability(String id) => liabilityMap[id];
  PortfolioAccount portfolioAccount(String accountName) =>
      portfolioAccountMap[accountName];
  Holding holding(String accountName, String holdingName) =>
      portfolioAccountMap[accountName].holding(holdingName);

  visitAccountHoldings(String accountName, HoldingVisitor visitor) =>
      portfolioAccountMap[accountName]._visitHoldings(accountName, visitor);

  visitPortfolioAccounts(PortfolioAccountVisitor visitor) => portfolioAccountMap
      .forEach((String accountName, PortfolioAccount portfolioAccount) =>
          visitor(accountName, portfolioAccount));

  visitAssets(AssetVisitor visitor) => assetMap
      .forEach((String assetName, Asset asset) => visitor(assetName, asset));

  visitLiabilities(LiabilityVisitor visitor) => liabilityMap.forEach(
      (String liabilityName, Liability liability) =>
          visitor(liabilityName, liability));

  visitHoldings(HoldingVisitor visitor) => visitPortfolioAccounts(
      (String accountName, PortfolioAccount portfolioAccount) =>
          portfolioAccount._visitHoldings(accountName, visitor));

  Iterable<HoldingKey> get holdingKeys {
    if (_holdingKeys == null) {
      _holdingKeys = [];
      visitHoldings((String account, String symbol, Holding holding) =>
          _holdingKeys.add(new HoldingKey(account, symbol)));
    }
    return _holdingKeys;
  }

  Map<AccountType, List<String>> get accountsByType {
    if (_accountsByType == null) {
      _accountsByType = new Map<AccountType, List<String>>();
      visitPortfolioAccounts(
          (String accountName, PortfolioAccount portfolioAccount) {
        _accountsByType.putIfAbsent(portfolioAccount.accountType, () => []);
        _accountsByType[portfolioAccount.accountType].add(accountName);
      });
    }
    return _accountsByType;
  }

  Iterable<String> get assetKeys => assetMap.keys;
  Iterable<String> get liabilityKeys => liabilityMap.keys;

  // end <class BalanceSheet>

  Map toJson() => {
    "asOf": ebisu_utils.toJson(asOf),
    "assetMap": ebisu_utils.toJson(assetMap),
    "liabilityMap": ebisu_utils.toJson(liabilityMap),
    "portfolioAccountMap": ebisu_utils.toJson(portfolioAccountMap),
  };

  static BalanceSheet fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new BalanceSheet._fromJsonMapImpl(json);
  }

  BalanceSheet._fromJsonMapImpl(Map jsonMap)
      : asOf = Date.fromJson(jsonMap["asOf"]),
        // assetMap is Map<String,Asset>
        assetMap = ebisu_utils.constructMapFromJsonData(
            jsonMap["assetMap"], (value) => Asset.fromJson(value)),
        // liabilityMap is Map<String,Liability>
        liabilityMap = ebisu_utils.constructMapFromJsonData(
            jsonMap["liabilityMap"], (value) => Liability.fromJson(value)),
        // portfolioAccountMap is Map<String,PortfolioAccount>
        portfolioAccountMap = ebisu_utils.constructMapFromJsonData(
            jsonMap["portfolioAccountMap"],
            (value) => PortfolioAccount.fromJson(value));

  BalanceSheet._copy(BalanceSheet other)
      : asOf = other.asOf,
        assetMap = valueApply(
            other.assetMap, (v) => v == null ? null : v.copy()),
        liabilityMap = valueApply(
            other.liabilityMap, (v) => v == null ? null : v.copy()),
        portfolioAccountMap = valueApply(
            other.portfolioAccountMap, (v) => v == null ? null : v.copy()),
        _accountsByType = valueApply(other._accountsByType, (v) => v == null
            ? null
            : (new List.from(v.map((e) => e == null ? null : e.copy())))),
        _holdingKeys = other._holdingKeys == null
            ? null
            : (new List.from(
                other._holdingKeys.map((e) => e == null ? null : e.copy())));

  Map<AccountType, List<String>> _accountsByType;
  List<HoldingKey> _holdingKeys;
}

Random _randomJsonGenerator = new Random(0);
// custom <library balance_sheet>

mergeHoldingTypes(HoldingType first, HoldingType second) {
  assert(first != null && second != null);
  return (first != second) ? HoldingType.BLEND : first;
}

typedef void PortfolioAccountVisitor(
    String accountName, PortfolioAccount portfolioAccount);
typedef void HoldingVisitor(
    String account, String holdingName, Holding holding);
typedef void AssetVisitor(String assetName, Asset asset);
typedef void LiabilityVisitor(String liabilityName, Liability liability);

main() {}

// end <library balance_sheet>
