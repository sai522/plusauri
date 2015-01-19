library plus.models.income_statement;

import 'common.dart';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/map_utilities.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

import 'package:plus/time_series.dart';

// end <additional imports>

final _logger = new Logger('income_statement');

class IncomeType implements Comparable<IncomeType> {
  static const OTHER = const IncomeType._(0);
  static const INTEREST_INCOME = const IncomeType._(1);
  static const CAPITAL_GAIN = const IncomeType._(2);
  static const LONG_TERM_CAPITAL_GAIN = const IncomeType._(3);
  static const SHORT_TERM_CAPITAL_GAIN = const IncomeType._(4);
  static const QUALIFIED_DIVIDEND_INCOME = const IncomeType._(5);
  static const NONQUALIFIED_DIVIDEND_INCOME = const IncomeType._(6);
  static const CAPITAL_GAIN_DISTRIBUTION_INCOME = const IncomeType._(7);
  static const INHERITANCE_INCOME = const IncomeType._(8);
  static const PENSION_INCOME = const IncomeType._(9);
  static const RENTAL_INCOME = const IncomeType._(10);
  static const SOCIAL_SECURITY_INCOME = const IncomeType._(11);
  static const LABOR_INCOME = const IncomeType._(12);
  static const LOTTERY_INCOME = const IncomeType._(13);

  static get values => [
    OTHER,
    INTEREST_INCOME,
    CAPITAL_GAIN,
    LONG_TERM_CAPITAL_GAIN,
    SHORT_TERM_CAPITAL_GAIN,
    QUALIFIED_DIVIDEND_INCOME,
    NONQUALIFIED_DIVIDEND_INCOME,
    CAPITAL_GAIN_DISTRIBUTION_INCOME,
    INHERITANCE_INCOME,
    PENSION_INCOME,
    RENTAL_INCOME,
    SOCIAL_SECURITY_INCOME,
    LABOR_INCOME,
    LOTTERY_INCOME
  ];

  final int value;

  int get hashCode => value;

  const IncomeType._(this.value);

  copy() => this;

  int compareTo(IncomeType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case OTHER: return "Other";
      case INTEREST_INCOME: return "InterestIncome";
      case CAPITAL_GAIN: return "CapitalGain";
      case LONG_TERM_CAPITAL_GAIN: return "LongTermCapitalGain";
      case SHORT_TERM_CAPITAL_GAIN: return "ShortTermCapitalGain";
      case QUALIFIED_DIVIDEND_INCOME: return "QualifiedDividendIncome";
      case NONQUALIFIED_DIVIDEND_INCOME: return "NonqualifiedDividendIncome";
      case CAPITAL_GAIN_DISTRIBUTION_INCOME: return "CapitalGainDistributionIncome";
      case INHERITANCE_INCOME: return "InheritanceIncome";
      case PENSION_INCOME: return "PensionIncome";
      case RENTAL_INCOME: return "RentalIncome";
      case SOCIAL_SECURITY_INCOME: return "SocialSecurityIncome";
      case LABOR_INCOME: return "LaborIncome";
      case LOTTERY_INCOME: return "LotteryIncome";
    }
    return null;
  }

  static IncomeType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Other": return OTHER;
      case "InterestIncome": return INTEREST_INCOME;
      case "CapitalGain": return CAPITAL_GAIN;
      case "LongTermCapitalGain": return LONG_TERM_CAPITAL_GAIN;
      case "ShortTermCapitalGain": return SHORT_TERM_CAPITAL_GAIN;
      case "QualifiedDividendIncome": return QUALIFIED_DIVIDEND_INCOME;
      case "NonqualifiedDividendIncome": return NONQUALIFIED_DIVIDEND_INCOME;
      case "CapitalGainDistributionIncome": return CAPITAL_GAIN_DISTRIBUTION_INCOME;
      case "InheritanceIncome": return INHERITANCE_INCOME;
      case "PensionIncome": return PENSION_INCOME;
      case "RentalIncome": return RENTAL_INCOME;
      case "SocialSecurityIncome": return SOCIAL_SECURITY_INCOME;
      case "LaborIncome": return LABOR_INCOME;
      case "LotteryIncome": return LOTTERY_INCOME;
      default: return null;
    }
  }

  int toJson() => value;
  static IncomeType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(14)].toString();
  }

}

class ExpenseType implements Comparable<ExpenseType> {
  static const OTHER = const ExpenseType._(0);
  static const INTEREST_EXPENSE = const ExpenseType._(1);
  static const CAPITAL_DEPRECIATION = const ExpenseType._(2);
  static const LONG_TERM_CAPITAL_LOSS = const ExpenseType._(3);
  static const SHORT_TERM_CAPITAL_LOSS = const ExpenseType._(4);
  static const LIVING_EXPENSE = const ExpenseType._(5);
  static const PENSION_CONTRIBUTION = const ExpenseType._(6);
  static const AUTO_EXPENSE = const ExpenseType._(7);
  static const COLLEGE_EXPENSE = const ExpenseType._(8);
  static const MEDICAL_EXPENSE = const ExpenseType._(9);
  static const ALIMONY = const ExpenseType._(10);
  static const PALIMONY = const ExpenseType._(11);
  static const CHARITABLE_DONATION = const ExpenseType._(12);
  static const TAXES_FEDERAL = const ExpenseType._(13);
  static const TAXES_STATE = const ExpenseType._(14);
  static const TAXES_PROPERTY = const ExpenseType._(15);
  static const DEBT_MORTGAGE = const ExpenseType._(16);
  static const DEBT_COLLEGE = const ExpenseType._(17);

  static get values => [
    OTHER,
    INTEREST_EXPENSE,
    CAPITAL_DEPRECIATION,
    LONG_TERM_CAPITAL_LOSS,
    SHORT_TERM_CAPITAL_LOSS,
    LIVING_EXPENSE,
    PENSION_CONTRIBUTION,
    AUTO_EXPENSE,
    COLLEGE_EXPENSE,
    MEDICAL_EXPENSE,
    ALIMONY,
    PALIMONY,
    CHARITABLE_DONATION,
    TAXES_FEDERAL,
    TAXES_STATE,
    TAXES_PROPERTY,
    DEBT_MORTGAGE,
    DEBT_COLLEGE
  ];

  final int value;

  int get hashCode => value;

  const ExpenseType._(this.value);

  copy() => this;

  int compareTo(ExpenseType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case OTHER: return "Other";
      case INTEREST_EXPENSE: return "InterestExpense";
      case CAPITAL_DEPRECIATION: return "CapitalDepreciation";
      case LONG_TERM_CAPITAL_LOSS: return "LongTermCapitalLoss";
      case SHORT_TERM_CAPITAL_LOSS: return "ShortTermCapitalLoss";
      case LIVING_EXPENSE: return "LivingExpense";
      case PENSION_CONTRIBUTION: return "PensionContribution";
      case AUTO_EXPENSE: return "AutoExpense";
      case COLLEGE_EXPENSE: return "CollegeExpense";
      case MEDICAL_EXPENSE: return "MedicalExpense";
      case ALIMONY: return "Alimony";
      case PALIMONY: return "Palimony";
      case CHARITABLE_DONATION: return "CharitableDonation";
      case TAXES_FEDERAL: return "TaxesFederal";
      case TAXES_STATE: return "TaxesState";
      case TAXES_PROPERTY: return "TaxesProperty";
      case DEBT_MORTGAGE: return "DebtMortgage";
      case DEBT_COLLEGE: return "DebtCollege";
    }
    return null;
  }

  static ExpenseType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Other": return OTHER;
      case "InterestExpense": return INTEREST_EXPENSE;
      case "CapitalDepreciation": return CAPITAL_DEPRECIATION;
      case "LongTermCapitalLoss": return LONG_TERM_CAPITAL_LOSS;
      case "ShortTermCapitalLoss": return SHORT_TERM_CAPITAL_LOSS;
      case "LivingExpense": return LIVING_EXPENSE;
      case "PensionContribution": return PENSION_CONTRIBUTION;
      case "AutoExpense": return AUTO_EXPENSE;
      case "CollegeExpense": return COLLEGE_EXPENSE;
      case "MedicalExpense": return MEDICAL_EXPENSE;
      case "Alimony": return ALIMONY;
      case "Palimony": return PALIMONY;
      case "CharitableDonation": return CHARITABLE_DONATION;
      case "TaxesFederal": return TAXES_FEDERAL;
      case "TaxesState": return TAXES_STATE;
      case "TaxesProperty": return TAXES_PROPERTY;
      case "DebtMortgage": return DEBT_MORTGAGE;
      case "DebtCollege": return DEBT_COLLEGE;
      default: return null;
    }
  }

  int toJson() => value;
  static ExpenseType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(18)].toString();
  }

  // custom <enum ExpenseType>

  bool get isObligatory =>
      value == DEBT_MORTGAGE.value || value == DEBT_COLLEGE.value;


  // end <enum ExpenseType>
}

class ItemSource implements Comparable<ItemSource> {
  static const BALANCE_SHEET = const ItemSource._(0);
  static const FLOW_MODEL = const ItemSource._(1);

  static get values => [
    BALANCE_SHEET,
    FLOW_MODEL
  ];

  final int value;

  int get hashCode => value;

  const ItemSource._(this.value);

  copy() => this;

  int compareTo(ItemSource other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case BALANCE_SHEET: return "BalanceSheet";
      case FLOW_MODEL: return "FlowModel";
    }
    return null;
  }

  static ItemSource fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "BalanceSheet": return BALANCE_SHEET;
      case "FlowModel": return FLOW_MODEL;
      default: return null;
    }
  }

  int toJson() => value;
  static ItemSource fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(2)].toString();
  }

}

class IncomeStatement {
  IncomeStatement();

  bool operator==(IncomeStatement other) =>
    identical(this, other) ||
    year == other.year &&
    const MapEquality().equals(incomes, other.incomes) &&
    const MapEquality().equals(expenses, other.expenses);

  int get hashCode => hash3(year, const MapEquality().hash(incomes), const MapEquality().hash(expenses));

  copy() => new IncomeStatement()
    ..year = year
    ..incomes = valueApply(incomes, (v) =>
    v == null? null : v.copy())
    ..expenses = valueApply(expenses, (v) =>
    v == null? null : v.copy());

  int year = 0;
  Map<String,IEItem> incomes = {};
  Map<String,IEItem> expenses = {};
  // custom <class IncomeStatement>

  Iterable<String> get incomeNames => incomes.keys;
  Iterable<String> get expenseNames => expenses.keys;

  // end <class IncomeStatement>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "year": ebisu_utils.toJson(year),
      "incomes": ebisu_utils.toJson(incomes),
      "expenses": ebisu_utils.toJson(expenses),
  };

  static IncomeStatement fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new IncomeStatement()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    year = jsonMap["year"];
    // incomes is Map<String,IEItem>
    incomes = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["incomes"],
        (value) => IEItem.fromJson(value))
    ;
    // expenses is Map<String,IEItem>
    expenses = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["expenses"],
        (value) => IEItem.fromJson(value))
  ;
  }
}

/// Create a IncomeStatement sans new, for more declarative construction
IncomeStatement
incomeStatement() =>
  new IncomeStatement();

class IEItem {
  IEItem();

  bool operator==(IEItem other) =>
    identical(this, other) ||
    source == other.source &&
    itemSource == other.itemSource &&
    details == other.details;

  int get hashCode => hash3(source, itemSource, details);

  copy() => new IEItem()
    ..source = source
    ..itemSource = itemSource == null? null : itemSource.copy()
    ..details = details == null? null : details.copy();

  String source;
  ItemSource itemSource;
  TimeSeries details;
  // custom <class IEItem>

  double get netCashFlow => details.sum;

  // end <class IEItem>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "source": ebisu_utils.toJson(source),
      "itemSource": ebisu_utils.toJson(itemSource),
      "details": ebisu_utils.toJson(details),
  };

  static IEItem fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new IEItem()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    source = jsonMap["source"];
    itemSource = ItemSource.fromJson(jsonMap["itemSource"]);
    details = TimeSeries.fromJson(jsonMap["details"]);
  }
}

/// Create a IEItem sans new, for more declarative construction
IEItem
iEItem() =>
  new IEItem();

Random _randomJsonGenerator = new Random(0);
// custom <library income_statement>

// end <library income_statement>
