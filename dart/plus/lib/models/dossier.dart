library plus.models.dossier;

import 'assumption.dart';
import 'balance_sheet.dart';
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
import 'package:plus/models/income_statement.dart';

// end <additional imports>

final _logger = new Logger('dossier');

class Person {
  Person();

  bool operator==(Person other) =>
    identical(this, other) ||
    birthDate == other.birthDate &&
    deathDate == other.deathDate &&
    retirementDate == other.retirementDate;

  int get hashCode => hash3(birthDate, deathDate, retirementDate);

  copy() => new Person()
    ..birthDate = birthDate
    ..deathDate = deathDate
    ..retirementDate = retirementDate;

  Date birthDate;
  Date deathDate;
  Date retirementDate;
  // custom <class Person>
  // end <class Person>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "birthDate": ebisu_utils.toJson(birthDate),
      "deathDate": ebisu_utils.toJson(deathDate),
      "retirementDate": ebisu_utils.toJson(retirementDate),
  };

  static Person fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Person()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    birthDate = Date.fromJson(jsonMap["birthDate"]);
    deathDate = Date.fromJson(jsonMap["deathDate"]);
    retirementDate = Date.fromJson(jsonMap["retirementDate"]);
  }
}

/// Create a Person sans new, for more declarative construction
Person
person() =>
  new Person();

class Dossier {
  Dossier(this.id, this.personMap, this.balanceSheet, this.flowModel,
    this.assumptionModel, this.alternateAssumptionModels, this.fundingLinks,
    this.investmentLinks);

  bool operator==(Dossier other) =>
    identical(this, other) ||
    id == other.id &&
    const MapEquality().equals(personMap, other.personMap) &&
    balanceSheet == other.balanceSheet &&
    flowModel == other.flowModel &&
    assumptionModel == other.assumptionModel &&
    const MapEquality().equals(alternateAssumptionModels, other.alternateAssumptionModels) &&
    const MapEquality().equals(fundingLinks, other.fundingLinks) &&
    const MapEquality().equals(investmentLinks, other.investmentLinks);

  int get hashCode => hashObjects([
    id,
    const MapEquality().hash(personMap),
    balanceSheet,
    flowModel,
    assumptionModel,
    const MapEquality().hash(alternateAssumptionModels),
    const MapEquality().hash(fundingLinks),
    const MapEquality().hash(investmentLinks)]);

  copy() => new Dossier._copy(this);
  final String id;
  final Map<String,Person> personMap;
  final BalanceSheet balanceSheet;
  final FlowModel flowModel;
  final AssumptionModel assumptionModel;
  final Map<String,AssumptionModel> alternateAssumptionModels;
  /// Links a flow model expense to an account for funding
  ///
  /// Note: A funding source can only be used its specified expense. However,
  /// expenses can be funded by other sources. The intent is to model constraints like
  /// college expenses being funded first by college funds.
  final Map<String,String> fundingLinks;
  /// Links a flow model income to one or more accounts.
  final Map<String,String> investmentLinks;
  // custom <class Dossier>

  Map<String, List<HoldingKey>> get incomePreferredLinks {
    if (_incomePreferredLinks == null) {
      _incomePreferredLinks = _buildFlowMap(investmentLinks);
    }
    return _incomePreferredLinks;
  }

  Map<String, List<HoldingKey>> get expensePreferredLinks {
    if (_expensePreferredLinks == null) {
      _expensePreferredLinks = _buildFlowMap(fundingLinks);
    }
    return _expensePreferredLinks;
  }

  Map<String, List<HoldingKey>> _buildFlowMap(Map<String, String> src) {
    Map<String, List<HoldingKey>> result = {};
    for (String flowName in src.keys) {
      final holdingKeyList = new List<HoldingKey>();
      result[flowName] = holdingKeyList;
      final accountName = src[flowName];

      holdingKeys.skipWhile(
          (HoldingKey key) =>
              key.accountName !=
                  accountName).takeWhile(
                      (HoldingKey key) =>
                          key.accountName ==
                              accountName).forEach((HoldingKey key) => holdingKeyList.add(key));
    }
    return result;
  }

  Map<ExpenseType, List<HoldingKey>> get preferredExpenseSources {
    if (_preferredExpenseSources == null) {
      final typeMap = accountsByType;

      _preferredExpenseSources = new Map<ExpenseType, List<HoldingKey>>();
      _ExpenseToAccountTypeLinks.forEach(
          (ExpenseType expenseType, List<AccountType> accountTypes) {
        for (final accountType in accountTypes) {
          final accounts = typeMap[accountType];
          if (accounts != null) {
            final accountHoldings = _preferredExpenseSources[expenseType] = [];
            for (final account in accounts) {
              balanceSheet.visitAccountHoldings(
                  account,
                  (String accountName, String holdingName, Holding holding) {
                if (holding != null) {
                  accountHoldings.add(new HoldingKey(accountName, holdingName));
                }
              });
            }
          }
        }
      });
    }
    return _preferredExpenseSources;
  }

  List<HoldingKey> get incomeHoldingKeys {
    if (_incomeHoldingKeys == null) {
      final allHoldingKeys = balanceSheet.holdingKeys;
      if (_incomePreferredLinks.length == 0) {
        _incomeHoldingKeys = balanceSheet.holdingKeys;
      } else {
        _incomeHoldingKeys = allHoldingKeys.where(
            (HoldingKey holdingKey) =>
                !incomePreferredLinks.containsValue(holdingKey)).toList(growable: false);
      }
    }
    return _incomeHoldingKeys;
  }

  bool _mapValuesContainsKey(Map<Object, List<HoldingKey>> map,
      HoldingKey key) {
    for (List<HoldingKey> keys in map.values) {
      if (keys.contains(key)) return true;
    }
    return false;
  }

  List<HoldingKey> get expenseHoldingKeys {
    if (_expenseHoldingKeys == null) {
      final allHoldingKeys = balanceSheet.holdingKeys;
      _expenseHoldingKeys = allHoldingKeys.where((HoldingKey holdingKey) {
        bool result =
            !_mapValuesContainsKey(preferredExpenseSources, holdingKey) &&
            !_mapValuesContainsKey(expensePreferredLinks, holdingKey);
        return result;
      }).toList(growable: false);
    }
    return _expenseHoldingKeys;
  }

  Map<AccountType, List<String>> get accountsByType =>
      balanceSheet.accountsByType;

  Iterable<HoldingKey> get holdingKeys => balanceSheet.holdingKeys;
  Iterable<String> get assetKeys => balanceSheet.assetKeys;
  Iterable<String> get liabilityKeys => balanceSheet.liabilityKeys;

  visitAssets(AssetVisitor visitor) => balanceSheet.visitAssets(visitor);
  visitLiabilities(LiabilityVisitor visitor) =>
      balanceSheet.visitLiabilities(visitor);

  PortfolioAccount portfolioAccount(String accountName) =>
      balanceSheet.portfolioAccount(accountName);

  Holding holding(HoldingKey holdingKey) {
    final result =
        balanceSheet.holding(holdingKey.accountName, holdingKey.holdingName);
    return result;
  }

  bool distributionsSheltered(String accountName) =>
      portfolioAccount(accountName).isDistributionSheltered;

  bool canCapitalGainBeSheltered(String accountName) =>
      portfolioAccount(accountName).canCapitalGainBeSheltered;

  // end <class Dossier>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "id": ebisu_utils.toJson(id),
      "personMap": ebisu_utils.toJson(personMap),
      "balanceSheet": ebisu_utils.toJson(balanceSheet),
      "flowModel": ebisu_utils.toJson(flowModel),
      "assumptionModel": ebisu_utils.toJson(assumptionModel),
      "alternateAssumptionModels": ebisu_utils.toJson(alternateAssumptionModels),
      "fundingLinks": ebisu_utils.toJson(fundingLinks),
      "investmentLinks": ebisu_utils.toJson(investmentLinks),
  };

  static Dossier fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Dossier._fromJsonMapImpl(json);
  }

  Dossier._fromJsonMapImpl(Map jsonMap) :
    id = jsonMap["id"],
    // personMap is Map<String,Person>
    personMap = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["personMap"],
        (value) => Person.fromJson(value)),
    balanceSheet = BalanceSheet.fromJson(jsonMap["balanceSheet"]),
    flowModel = FlowModel.fromJson(jsonMap["flowModel"]),
    assumptionModel = AssumptionModel.fromJson(jsonMap["assumptionModel"]),
    // alternateAssumptionModels is Map<String,AssumptionModel>
    alternateAssumptionModels = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["alternateAssumptionModels"],
        (value) => AssumptionModel.fromJson(value)),
    // fundingLinks is Map<String,String>
    fundingLinks = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["fundingLinks"],
        (value) => value),
    // investmentLinks is Map<String,String>
    investmentLinks = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["investmentLinks"],
        (value) => value);

  Dossier._copy(Dossier other) :
    id = other.id,
    personMap = valueApply(other.personMap, (v) =>
      v == null? null : v.copy()),
    balanceSheet = other.balanceSheet == null? null : other.balanceSheet.copy(),
    flowModel = other.flowModel == null? null : other.flowModel.copy(),
    assumptionModel = other.assumptionModel == null? null : other.assumptionModel.copy(),
    alternateAssumptionModels = valueApply(other.alternateAssumptionModels, (v) =>
      v == null? null : v.copy()),
    fundingLinks = valueApply(other.fundingLinks, (v) =>
      v),
    investmentLinks = valueApply(other.investmentLinks, (v) =>
      v),
    _incomePreferredLinks = valueApply(other._incomePreferredLinks, (v) =>
      v == null? null :
      (new List.from(v.map((e) =>
        e == null? null : e.copy())))),
    _expensePreferredLinks = valueApply(other._expensePreferredLinks, (v) =>
      v == null? null :
      (new List.from(v.map((e) =>
        e == null? null : e.copy())))),
    _preferredExpenseSources = valueApply(other._preferredExpenseSources, (v) =>
      v == null? null :
      (new List.from(v.map((e) =>
        e == null? null : e.copy())))),
    _incomeHoldingKeys = other._incomeHoldingKeys == null? null :
      (new List.from(other._incomeHoldingKeys.map((e) =>
        e == null? null : e.copy()))),
    _expenseHoldingKeys = other._expenseHoldingKeys == null? null :
      (new List.from(other._expenseHoldingKeys.map((e) =>
        e == null? null : e.copy())));

  Map<String,List<HoldingKey>> _incomePreferredLinks;
  Map<String,List<HoldingKey>> _expensePreferredLinks;
  /// Preferred source based on busines rules (eg College Expense paid by College Accounts)
  Map<ExpenseType,List<HoldingKey>> _preferredExpenseSources;
  /// List of sources that have not been covered by incomePreferredLinks
  List<HoldingKey> _incomeHoldingKeys;
  /// List of sources that have not been covered by expensePreferredLinks or preferredExpenseSources
  List<HoldingKey> _expenseHoldingKeys;
}

class DossierBuilder {
  DossierBuilder();

  String id;
  Map<String,Person> personMap = {};
  BalanceSheet balanceSheet;
  FlowModel flowModel;
  AssumptionModel assumptionModel;
  Map<String,AssumptionModel> alternateAssumptionModels = {};
  Map<String,String> fundingLinks = {};
  Map<String,String> investmentLinks = {};
  Map<String,List<HoldingKey>> incomePreferredLinks;
  Map<String,List<HoldingKey>> expensePreferredLinks;
  Map<ExpenseType,List<HoldingKey>> preferredExpenseSources;
  List<HoldingKey> incomeHoldingKeys;
  List<HoldingKey> expenseHoldingKeys;
  // custom <class DossierBuilder>
  // end <class DossierBuilder>
  Dossier buildInstance() => new Dossier(
    id, personMap, balanceSheet, flowModel, assumptionModel,
    alternateAssumptionModels, fundingLinks, investmentLinks);

  factory DossierBuilder.copyFrom(Dossier _) =>
    new DossierBuilder._copyImpl(_.copy());

  DossierBuilder._copyImpl(Dossier _) :
    id = _.id,
    personMap = _.personMap,
    balanceSheet = _.balanceSheet,
    flowModel = _.flowModel,
    assumptionModel = _.assumptionModel,
    alternateAssumptionModels = _.alternateAssumptionModels,
    fundingLinks = _.fundingLinks,
    investmentLinks = _.investmentLinks;


}

/// Create a DossierBuilder sans new, for more declarative construction
DossierBuilder
dossierBuilder() =>
  new DossierBuilder();


Random _randomJsonGenerator = new Random(0);
// custom <library dossier>

const _ExpenseToAccountTypeLinks = const {
  ExpenseType.COLLEGE_EXPENSE: const [AccountType.COLLEGE_IRS529],
  ExpenseType.MEDICAL_EXPENSE: const [AccountType.HEALTH_SAVINGS_ACCOUNT]
};

// end <library dossier>
