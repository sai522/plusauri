library plus.models.common;

import 'dart:convert' as convert;
import 'dart:math';
import 'package:collection/equality.dart';
import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
import 'package:logging/logging.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/map_utilities.dart';
import 'package:plus/time_series.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

// end <additional imports>

final _logger = new Logger('common');

class AccountType implements Comparable<AccountType> {
  static const OTHER = const AccountType._(0);
  static const ROTH_IRS401K = const AccountType._(1);
  static const TRADITIONAL_IRS401K = const AccountType._(2);
  static const COLLEGE_IRS529 = const AccountType._(3);
  static const TRADITIONAL_IRA = const AccountType._(4);
  static const INVESTMENT = const AccountType._(5);
  static const BROKERAGE = const AccountType._(6);
  static const CHECKING = const AccountType._(7);
  static const HEALTH_SAVINGS_ACCOUNT = const AccountType._(8);
  static const SAVINGS = const AccountType._(9);
  static const MONEY_MARKET = const AccountType._(10);
  static const MATTRESS = const AccountType._(11);

  static get values => [
    OTHER,
    ROTH_IRS401K,
    TRADITIONAL_IRS401K,
    COLLEGE_IRS529,
    TRADITIONAL_IRA,
    INVESTMENT,
    BROKERAGE,
    CHECKING,
    HEALTH_SAVINGS_ACCOUNT,
    SAVINGS,
    MONEY_MARKET,
    MATTRESS
  ];

  final int value;

  int get hashCode => value;

  const AccountType._(this.value);

  copy() => this;

  int compareTo(AccountType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case OTHER: return "Other";
      case ROTH_IRS401K: return "RothIrs401k";
      case TRADITIONAL_IRS401K: return "TraditionalIrs401k";
      case COLLEGE_IRS529: return "CollegeIrs529";
      case TRADITIONAL_IRA: return "TraditionalIra";
      case INVESTMENT: return "Investment";
      case BROKERAGE: return "Brokerage";
      case CHECKING: return "Checking";
      case HEALTH_SAVINGS_ACCOUNT: return "HealthSavingsAccount";
      case SAVINGS: return "Savings";
      case MONEY_MARKET: return "MoneyMarket";
      case MATTRESS: return "Mattress";
    }
    return null;
  }

  static AccountType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Other": return OTHER;
      case "RothIrs401k": return ROTH_IRS401K;
      case "TraditionalIrs401k": return TRADITIONAL_IRS401K;
      case "CollegeIrs529": return COLLEGE_IRS529;
      case "TraditionalIra": return TRADITIONAL_IRA;
      case "Investment": return INVESTMENT;
      case "Brokerage": return BROKERAGE;
      case "Checking": return CHECKING;
      case "HealthSavingsAccount": return HEALTH_SAVINGS_ACCOUNT;
      case "Savings": return SAVINGS;
      case "MoneyMarket": return MONEY_MARKET;
      case "Mattress": return MATTRESS;
      default: return null;
    }
  }

  int toJson() => value;
  static AccountType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(12)].toString();
  }

}

class AssetType implements Comparable<AssetType> {
  static const OTHER = const AssetType._(0);
  static const INVESTMENT = const AssetType._(1);
  static const PRIMARY_RESIDENCE = const AssetType._(2);
  static const FAMILY_PROPERTY = const AssetType._(3);
  static const FINANCIAL_INSTRUMENT = const AssetType._(4);
  static const AUTOMOBILE = const AssetType._(5);
  static const LIFE_INSURANCE_POLICY = const AssetType._(6);
  static const COMPANY_STOCK_OPTION = const AssetType._(7);
  static const SAVINGS = const AssetType._(8);
  static const COLLEGE_SAVINGS = const AssetType._(9);
  static const RETIREMENT_SAVINGS = const AssetType._(10);
  static const CASH = const AssetType._(11);
  static const RENTAL_PROPERTY = const AssetType._(12);

  static get values => [
    OTHER,
    INVESTMENT,
    PRIMARY_RESIDENCE,
    FAMILY_PROPERTY,
    FINANCIAL_INSTRUMENT,
    AUTOMOBILE,
    LIFE_INSURANCE_POLICY,
    COMPANY_STOCK_OPTION,
    SAVINGS,
    COLLEGE_SAVINGS,
    RETIREMENT_SAVINGS,
    CASH,
    RENTAL_PROPERTY
  ];

  final int value;

  int get hashCode => value;

  const AssetType._(this.value);

  copy() => this;

  int compareTo(AssetType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case OTHER: return "Other";
      case INVESTMENT: return "Investment";
      case PRIMARY_RESIDENCE: return "PrimaryResidence";
      case FAMILY_PROPERTY: return "FamilyProperty";
      case FINANCIAL_INSTRUMENT: return "FinancialInstrument";
      case AUTOMOBILE: return "Automobile";
      case LIFE_INSURANCE_POLICY: return "LifeInsurancePolicy";
      case COMPANY_STOCK_OPTION: return "CompanyStockOption";
      case SAVINGS: return "Savings";
      case COLLEGE_SAVINGS: return "CollegeSavings";
      case RETIREMENT_SAVINGS: return "RetirementSavings";
      case CASH: return "Cash";
      case RENTAL_PROPERTY: return "RentalProperty";
    }
    return null;
  }

  static AssetType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Other": return OTHER;
      case "Investment": return INVESTMENT;
      case "PrimaryResidence": return PRIMARY_RESIDENCE;
      case "FamilyProperty": return FAMILY_PROPERTY;
      case "FinancialInstrument": return FINANCIAL_INSTRUMENT;
      case "Automobile": return AUTOMOBILE;
      case "LifeInsurancePolicy": return LIFE_INSURANCE_POLICY;
      case "CompanyStockOption": return COMPANY_STOCK_OPTION;
      case "Savings": return SAVINGS;
      case "CollegeSavings": return COLLEGE_SAVINGS;
      case "RetirementSavings": return RETIREMENT_SAVINGS;
      case "Cash": return CASH;
      case "RentalProperty": return RENTAL_PROPERTY;
      default: return null;
    }
  }

  int toJson() => value;
  static AssetType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(13)].toString();
  }

}

class LiabilityType implements Comparable<LiabilityType> {
  static const OTHER = const LiabilityType._(0);
  static const MORTGAGE = const LiabilityType._(1);
  static const AUTO_LOAN = const LiabilityType._(2);
  static const COLLEGE_DEBT = const LiabilityType._(3);
  static const CREDIT_CARD_DEBT = const LiabilityType._(4);

  static get values => [
    OTHER,
    MORTGAGE,
    AUTO_LOAN,
    COLLEGE_DEBT,
    CREDIT_CARD_DEBT
  ];

  final int value;

  int get hashCode => value;

  const LiabilityType._(this.value);

  copy() => this;

  int compareTo(LiabilityType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case OTHER: return "Other";
      case MORTGAGE: return "Mortgage";
      case AUTO_LOAN: return "AutoLoan";
      case COLLEGE_DEBT: return "CollegeDebt";
      case CREDIT_CARD_DEBT: return "CreditCardDebt";
    }
    return null;
  }

  static LiabilityType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Other": return OTHER;
      case "Mortgage": return MORTGAGE;
      case "AutoLoan": return AUTO_LOAN;
      case "CollegeDebt": return COLLEGE_DEBT;
      case "CreditCardDebt": return CREDIT_CARD_DEBT;
      default: return null;
    }
  }

  int toJson() => value;
  static LiabilityType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(5)].toString();
  }

}

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

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(5)].toString();
  }

}

class InterpolationType implements Comparable<InterpolationType> {
  static const LINEAR = const InterpolationType._(0);
  static const STEP = const InterpolationType._(1);
  static const CUBIC = const InterpolationType._(2);

  static get values => [
    LINEAR,
    STEP,
    CUBIC
  ];

  final int value;

  int get hashCode => value;

  const InterpolationType._(this.value);

  copy() => this;

  int compareTo(InterpolationType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case LINEAR: return "Linear";
      case STEP: return "Step";
      case CUBIC: return "Cubic";
    }
    return null;
  }

  static InterpolationType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Linear": return LINEAR;
      case "Step": return STEP;
      case "Cubic": return CUBIC;
      default: return null;
    }
  }

  int toJson() => value;
  static InterpolationType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(3)].toString();
  }

}

class PaymentFrequency implements Comparable<PaymentFrequency> {
  static const ONCE = const PaymentFrequency._(0);
  static const MONTHLY = const PaymentFrequency._(1);
  static const SEMIANNUAL = const PaymentFrequency._(2);
  static const ANNUAL = const PaymentFrequency._(3);

  static get values => [
    ONCE,
    MONTHLY,
    SEMIANNUAL,
    ANNUAL
  ];

  final int value;

  int get hashCode => value;

  const PaymentFrequency._(this.value);

  copy() => this;

  int compareTo(PaymentFrequency other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case ONCE: return "Once";
      case MONTHLY: return "Monthly";
      case SEMIANNUAL: return "Semiannual";
      case ANNUAL: return "Annual";
    }
    return null;
  }

  static PaymentFrequency fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Once": return ONCE;
      case "Monthly": return MONTHLY;
      case "Semiannual": return SEMIANNUAL;
      case "Annual": return ANNUAL;
      default: return null;
    }
  }

  int toJson() => value;
  static PaymentFrequency fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(4)].toString();
  }

}

class TaxCategory implements Comparable<TaxCategory> {
  static const LABOR_INCOME = const TaxCategory._(0);
  static const INTEREST_INCOME = const TaxCategory._(1);
  static const QUALIFIED_DIVIDEND_INCOME = const TaxCategory._(2);
  static const UNQUALIFIED_DIVIDEND_INCOME = const TaxCategory._(3);
  static const SHORT_TERM_CAPITAL_GAIN = const TaxCategory._(4);
  static const LONG_TERM_CAPITAL_GAIN = const TaxCategory._(5);
  static const SOCIAL_SECURITY_INCOME = const TaxCategory._(6);
  static const PENSION_INCOME = const TaxCategory._(7);
  static const OTHER_ORDINARY_INCOME = const TaxCategory._(8);
  static const INHERITANCE = const TaxCategory._(9);
  static const RENTAL_INCOME = const TaxCategory._(10);
  static const PROPERTY_VALUE = const TaxCategory._(11);

  static get values => [
    LABOR_INCOME,
    INTEREST_INCOME,
    QUALIFIED_DIVIDEND_INCOME,
    UNQUALIFIED_DIVIDEND_INCOME,
    SHORT_TERM_CAPITAL_GAIN,
    LONG_TERM_CAPITAL_GAIN,
    SOCIAL_SECURITY_INCOME,
    PENSION_INCOME,
    OTHER_ORDINARY_INCOME,
    INHERITANCE,
    RENTAL_INCOME,
    PROPERTY_VALUE
  ];

  final int value;

  int get hashCode => value;

  const TaxCategory._(this.value);

  copy() => this;

  int compareTo(TaxCategory other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case LABOR_INCOME: return "LaborIncome";
      case INTEREST_INCOME: return "InterestIncome";
      case QUALIFIED_DIVIDEND_INCOME: return "QualifiedDividendIncome";
      case UNQUALIFIED_DIVIDEND_INCOME: return "UnqualifiedDividendIncome";
      case SHORT_TERM_CAPITAL_GAIN: return "ShortTermCapitalGain";
      case LONG_TERM_CAPITAL_GAIN: return "LongTermCapitalGain";
      case SOCIAL_SECURITY_INCOME: return "SocialSecurityIncome";
      case PENSION_INCOME: return "PensionIncome";
      case OTHER_ORDINARY_INCOME: return "OtherOrdinaryIncome";
      case INHERITANCE: return "Inheritance";
      case RENTAL_INCOME: return "RentalIncome";
      case PROPERTY_VALUE: return "PropertyValue";
    }
    return null;
  }

  static TaxCategory fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "LaborIncome": return LABOR_INCOME;
      case "InterestIncome": return INTEREST_INCOME;
      case "QualifiedDividendIncome": return QUALIFIED_DIVIDEND_INCOME;
      case "UnqualifiedDividendIncome": return UNQUALIFIED_DIVIDEND_INCOME;
      case "ShortTermCapitalGain": return SHORT_TERM_CAPITAL_GAIN;
      case "LongTermCapitalGain": return LONG_TERM_CAPITAL_GAIN;
      case "SocialSecurityIncome": return SOCIAL_SECURITY_INCOME;
      case "PensionIncome": return PENSION_INCOME;
      case "OtherOrdinaryIncome": return OTHER_ORDINARY_INCOME;
      case "Inheritance": return INHERITANCE;
      case "RentalIncome": return RENTAL_INCOME;
      case "PropertyValue": return PROPERTY_VALUE;
      default: return null;
    }
  }

  int toJson() => value;
  static TaxCategory fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(12)].toString();
  }

}

class TaxType implements Comparable<TaxType> {
  static const ORDINARY_INCOME = const TaxType._(0);
  static const QUALIFIED_DIVIDEND = const TaxType._(1);
  static const LONG_TERM_CAPITAL_GAIN = const TaxType._(2);
  static const SHORT_TERM_CAPITAL_GAIN = const TaxType._(3);
  static const INHERITANCE = const TaxType._(4);
  static const MEDICARE = const TaxType._(5);
  static const SOCIAL_SECURITY = const TaxType._(6);
  static const PROPERTY = const TaxType._(7);

  static get values => [
    ORDINARY_INCOME,
    QUALIFIED_DIVIDEND,
    LONG_TERM_CAPITAL_GAIN,
    SHORT_TERM_CAPITAL_GAIN,
    INHERITANCE,
    MEDICARE,
    SOCIAL_SECURITY,
    PROPERTY
  ];

  final int value;

  int get hashCode => value;

  const TaxType._(this.value);

  copy() => this;

  int compareTo(TaxType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case ORDINARY_INCOME: return "OrdinaryIncome";
      case QUALIFIED_DIVIDEND: return "QualifiedDividend";
      case LONG_TERM_CAPITAL_GAIN: return "LongTermCapitalGain";
      case SHORT_TERM_CAPITAL_GAIN: return "ShortTermCapitalGain";
      case INHERITANCE: return "Inheritance";
      case MEDICARE: return "Medicare";
      case SOCIAL_SECURITY: return "SocialSecurity";
      case PROPERTY: return "Property";
    }
    return null;
  }

  static TaxType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "OrdinaryIncome": return ORDINARY_INCOME;
      case "QualifiedDividend": return QUALIFIED_DIVIDEND;
      case "LongTermCapitalGain": return LONG_TERM_CAPITAL_GAIN;
      case "ShortTermCapitalGain": return SHORT_TERM_CAPITAL_GAIN;
      case "Inheritance": return INHERITANCE;
      case "Medicare": return MEDICARE;
      case "SocialSecurity": return SOCIAL_SECURITY;
      case "Property": return PROPERTY;
      default: return null;
    }
  }

  int toJson() => value;
  static TaxType fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(8)].toString();
  }

}

class TaxingAuthority implements Comparable<TaxingAuthority> {
  static const FEDERAL = const TaxingAuthority._(0);
  static const STATE = const TaxingAuthority._(1);

  static get values => [
    FEDERAL,
    STATE
  ];

  final int value;

  int get hashCode => value;

  const TaxingAuthority._(this.value);

  copy() => this;

  int compareTo(TaxingAuthority other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case FEDERAL: return "Federal";
      case STATE: return "State";
    }
    return null;
  }

  static TaxingAuthority fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Federal": return FEDERAL;
      case "State": return STATE;
      default: return null;
    }
  }

  int toJson() => value;
  static TaxingAuthority fromJson(int v) {
    return v==null? null : values[v];
  }

  static String randJson() {
   return values[_randomJsonGenerator.nextInt(2)].toString();
  }

}

class Point {
  const Point(this.x, this.y);

  bool operator==(Point other) =>
    identical(this, other) ||
    x == other.x &&
    y == other.y;

  int get hashCode => hash2(x, y);

  copy() => new Point._copy(this);
  final num x;
  final num y;
  // custom <class Point>

  // end <class Point>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "x": ebisu_utils.toJson(x),
      "y": ebisu_utils.toJson(y),
  };

  static Point fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Point._fromJsonMapImpl(json);
  }

  Point._fromJsonMapImpl(Map jsonMap) :
    x = jsonMap["x"],
    y = jsonMap["y"];

  Point._copy(Point other) :
    x = other.x,
    y = other.y;

}

class CostBasis {
  CostBasis(this.units, this.unitValue) { _init(); }

  bool operator==(CostBasis other) =>
    identical(this, other) ||
    units == other.units &&
    unitValue == other.unitValue;

  int get hashCode => hash2(units, unitValue);

  copy() => new CostBasis._copy(this);
  final double units;
  final double unitValue;
  // custom <class CostBasis>

  _init() {
    assert(units.isFinite && unitValue.isFinite);
  }

  double get marketValue => units * unitValue;

  CostBasis operator +(CostBasis other) {
    if (units == 0.0) {
      return other;
    } else if (other.units == 0.0) {
      return this;
    } else {
      double sumUnits = units + other.units;
      if (sumUnits == 0.0) return NoCostBasis;
      return new CostBasis(
          sumUnits,
          (marketValue + other.marketValue) / sumUnits);
    }
  }

  CostBasis operator -() =>
      identical(this, NoCostBasis) ? NoCostBasis : new CostBasis(-units, unitValue);

  CostBasis operator -(CostBasis other) => this + (-other);

  // end <class CostBasis>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "units": ebisu_utils.toJson(units),
      "unitValue": ebisu_utils.toJson(unitValue),
  };

  static CostBasis fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new CostBasis._fromJsonMapImpl(json);
  }

  CostBasis._fromJsonMapImpl(Map jsonMap) :
    units = jsonMap["units"],
    unitValue = jsonMap["unitValue"];

  CostBasis._copy(CostBasis other) :
    units = other.units,
    unitValue = other.unitValue;

}

class QuantityBin {
  QuantityBin();

  bool operator==(QuantityBin other) =>
    identical(this, other) ||
    interpolationType == other.interpolationType &&
    const ListEquality().equals(data, other.data);

  int get hashCode => hash2(interpolationType, const ListEquality<Point>().hash(data));

  copy() => new QuantityBin()
    ..interpolationType = interpolationType == null? null : interpolationType.copy()
    ..data = data == null? null :
    (new List.from(data.map((e) =>
      e == null? null : e.copy())));

  InterpolationType interpolationType;
  List<Point> data = [];
  // custom <class QuantityBin>
  // end <class QuantityBin>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "interpolationType": ebisu_utils.toJson(interpolationType),
      "data": ebisu_utils.toJson(data),
  };

  static QuantityBin fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new QuantityBin()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    interpolationType = InterpolationType.fromJson(jsonMap["interpolationType"]);
    // data is List<Point>
    data = ebisu_utils
      .constructListFromJsonData(jsonMap["data"],
                                 (data) => Point.fromJson(data))
  ;
  }
}

/// Create a QuantityBin sans new, for more declarative construction
QuantityBin
quantityBin() =>
  new QuantityBin();

class CapitalizationPartition {
  const CapitalizationPartition(this.smallCap, this.midCap, this.largeCap);

  bool operator==(CapitalizationPartition other) =>
    identical(this, other) ||
    smallCap == other.smallCap &&
    midCap == other.midCap &&
    largeCap == other.largeCap;

  int get hashCode => hash3(smallCap, midCap, largeCap);

  copy() => new CapitalizationPartition._copy(this);
  final double smallCap;
  final double midCap;
  final double largeCap;
  // custom <class CapitalizationPartition>

  const CapitalizationPartition.empty()
      : smallCap = 0.0,
        midCap = 0.0,
        largeCap = 0.0;

  CapitalizationPartition.fromPartitionMap(Map map)
      : smallCap = map.containsKey('smallCap') ? map['smallCap'] : 0.0,
        midCap = map.containsKey('midCap') ? map['midCap'] : 0.0,
        largeCap = map.containsKey('largeCap') ? map['largeCap'] : 0.0;

  Map get partitionMap {
    final result = {};
    if (smallCap != 0.0) result['smallCap'] = smallCap;
    if (midCap != 0.0) result['midCap'] = midCap;
    if (largeCap != 0.0) result['largeCap'] = largeCap;
    return result;
  }

  // end <class CapitalizationPartition>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "smallCap": ebisu_utils.toJson(smallCap),
      "midCap": ebisu_utils.toJson(midCap),
      "largeCap": ebisu_utils.toJson(largeCap),
  };

  static CapitalizationPartition fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new CapitalizationPartition._fromJsonMapImpl(json);
  }

  CapitalizationPartition._fromJsonMapImpl(Map jsonMap) :
    smallCap = jsonMap["smallCap"],
    midCap = jsonMap["midCap"],
    largeCap = jsonMap["largeCap"];

  CapitalizationPartition._copy(CapitalizationPartition other) :
    smallCap = other.smallCap,
    midCap = other.midCap,
    largeCap = other.largeCap;

}

class InvestmentStylePartition {
  const InvestmentStylePartition(this.value, this.blend, this.growth);

  bool operator==(InvestmentStylePartition other) =>
    identical(this, other) ||
    value == other.value &&
    blend == other.blend &&
    growth == other.growth;

  int get hashCode => hash3(value, blend, growth);

  copy() => new InvestmentStylePartition._copy(this);
  final double value;
  final double blend;
  final double growth;
  // custom <class InvestmentStylePartition>

  const InvestmentStylePartition.empty()
      : value = 0.0,
        blend = 0.0,
        growth = 0.0;

  InvestmentStylePartition.fromPartitionMap(Map map)
      : value = map.containsKey('value') ? map['value'] : 0.0,
        blend = map.containsKey('blend') ? map['blend'] : 0.0,
        growth = map.containsKey('growth') ? map['growth'] : 0.0;

  Map get partitionMap {
    final result = {};
    if (value != 0.0) result['value'] = value;
    if (blend != 0.0) result['blend'] = blend;
    if (growth != 0.0) result['growth'] = growth;
    return result;
  }

  // end <class InvestmentStylePartition>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "value": ebisu_utils.toJson(value),
      "blend": ebisu_utils.toJson(blend),
      "growth": ebisu_utils.toJson(growth),
  };

  static InvestmentStylePartition fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new InvestmentStylePartition._fromJsonMapImpl(json);
  }

  InvestmentStylePartition._fromJsonMapImpl(Map jsonMap) :
    value = jsonMap["value"],
    blend = jsonMap["blend"],
    growth = jsonMap["growth"];

  InvestmentStylePartition._copy(InvestmentStylePartition other) :
    value = other.value,
    blend = other.blend,
    growth = other.growth;

}

class AllocationPartition {
  const AllocationPartition(this.stock, this.bond, this.cash, this.other);

  bool operator==(AllocationPartition other) =>
    identical(this, other) ||
    stock == other.stock &&
    bond == other.bond &&
    cash == other.cash &&
    this.other == other.other;

  int get hashCode => hash4(stock,
    bond,
    cash,
    other);

  copy() => new AllocationPartition._copy(this);
  final double stock;
  final double bond;
  final double cash;
  final double other;
  // custom <class AllocationPartition>

  const AllocationPartition.empty()
      : stock = 0.0,
        bond = 0.0,
        cash = 0.0,
        other = 0.0;

  AllocationPartition.fromPartitionMap(Map map)
      : stock = (map.containsKey('stock') ? map['stock'] : 0.0),
        bond = (map.containsKey('bond') ? map['bond'] : 0.0),
        cash = (map.containsKey('cash') ? map['cash'] : 0.0),
        other = (map.containsKey('other') ? map['other'] : 0.0);

  Map get partitionMap {
    final result = {};
    if (stock != 0.0) result['stock'] = stock;
    if (bond != 0.0) result['bond'] = bond;
    if (cash != 0.0) result['cash'] = cash;
    if (other != 0.0) result['other'] = other;
    return result;
  }

  // end <class AllocationPartition>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "stock": ebisu_utils.toJson(stock),
      "bond": ebisu_utils.toJson(bond),
      "cash": ebisu_utils.toJson(cash),
      "other": ebisu_utils.toJson(other),
  };

  static AllocationPartition fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new AllocationPartition._fromJsonMapImpl(json);
  }

  AllocationPartition._fromJsonMapImpl(Map jsonMap) :
    stock = jsonMap["stock"],
    bond = jsonMap["bond"],
    cash = jsonMap["cash"],
    other = jsonMap["other"];

  AllocationPartition._copy(AllocationPartition other) :
    stock = other.stock,
    bond = other.bond,
    cash = other.cash,
    other = other.other;

}

class InstrumentPartitions {
  const InstrumentPartitions(this.allocationPartition,
    this.investmentStylePartition, this.capitalizationPartition);

  bool operator==(InstrumentPartitions other) =>
    identical(this, other) ||
    allocationPartition == other.allocationPartition &&
    investmentStylePartition == other.investmentStylePartition &&
    capitalizationPartition == other.capitalizationPartition;

  int get hashCode => hash3(allocationPartition, investmentStylePartition, capitalizationPartition);

  copy() => new InstrumentPartitions._copy(this);
  final AllocationPartition allocationPartition;
  final InvestmentStylePartition investmentStylePartition;
  final CapitalizationPartition capitalizationPartition;
  // custom <class InstrumentPartitions>

  const InstrumentPartitions.empty()
      : allocationPartition = const AllocationPartition.empty(),
        investmentStylePartition = const InvestmentStylePartition.empty(),
        capitalizationPartition = const CapitalizationPartition.empty();

  double blendedDistance(InstrumentPartitions other) =>
      valueDistance(
          allocationPartition.partitionMap,
          other.allocationPartition.partitionMap) +
          valueDistance(
              investmentStylePartition.partitionMap,
              other.investmentStylePartition.partitionMap) +
          valueDistance(
              capitalizationPartition.partitionMap,
              other.capitalizationPartition.partitionMap);


  // end <class InstrumentPartitions>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "allocationPartition": ebisu_utils.toJson(allocationPartition),
      "investmentStylePartition": ebisu_utils.toJson(investmentStylePartition),
      "capitalizationPartition": ebisu_utils.toJson(capitalizationPartition),
  };

  static InstrumentPartitions fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new InstrumentPartitions._fromJsonMapImpl(json);
  }

  InstrumentPartitions._fromJsonMapImpl(Map jsonMap) :
    allocationPartition = AllocationPartition.fromJson(jsonMap["allocationPartition"]),
    investmentStylePartition = InvestmentStylePartition.fromJson(jsonMap["investmentStylePartition"]),
    capitalizationPartition = CapitalizationPartition.fromJson(jsonMap["capitalizationPartition"]);

  InstrumentPartitions._copy(InstrumentPartitions other) :
    allocationPartition = other.allocationPartition == null? null : other.allocationPartition.copy(),
    investmentStylePartition = other.investmentStylePartition == null? null : other.investmentStylePartition.copy(),
    capitalizationPartition = other.capitalizationPartition == null? null : other.capitalizationPartition.copy();

}

/// Specifies a value that has been partitioned by the partition map
/// (i.e. percentages summing to 1.0), as well the value unpartitioned.  The
/// motivation is to allow aggregation of potentially unpartitioned values as well
/// as the paritioned values according to the percentages provided.
///
class PartitionMapping {
  const PartitionMapping(this.partitioned, this.unpartitioned, this.partitionMap);

  bool operator==(PartitionMapping other) =>
    identical(this, other) ||
    partitioned == other.partitioned &&
    unpartitioned == other.unpartitioned &&
    const MapEquality().equals(partitionMap, other.partitionMap);

  int get hashCode => hash3(partitioned, unpartitioned, const MapEquality().hash(partitionMap));

  copy() => new PartitionMapping._copy(this);
  final double partitioned;
  final double unpartitioned;
  final Map<String,double> partitionMap;
  // custom <class PartitionMapping>

  PartitionMapping.validated(this.partitioned, this.unpartitioned,
      this.partitionMap) {
    if (!isValid) throw new ArgumentError(
        'Partitioning must sum to 1.0 => $partitionMap');
  }

  const PartitionMapping.empty()
      : partitioned = 0.0,
        unpartitioned = 0.0,
        partitionMap = const {};

  double get total => partitioned + unpartitioned;
  double percent(String key) =>
      partitionMap.containsKey(key) ? partitionMap[key] : 0.0;

  double value(String key) => percent(key) * total;
  double percentOfTotal(String key) => value(key) / total;
  double get percentUnpartitioned => unpartitioned / total;

  Map get percentOfTotalMap {
    final total = this.total;
    return valueApply(partitionMap, (k) => value(k) / total);
  }

  double distance(PartitionMapping other) =>
      valueDistance(partitionMap, other.partitionMap);

  PartitionMapping operator +(PartitionMapping other) {
    final totalPartitioned = partitioned + other.partitioned;
    final totalUnpartitioned = unpartitioned + other.unpartitioned;
    final totalValue = totalPartitioned + totalUnpartitioned;
    assert((totalValue - total - other.total).abs() < 0.001);

    if (totalPartitioned ==
        0.0) return new PartitionMapping(0.0, totalValue, const {});

    final map = {};
    final keys = _keyUnion(other);

    keys.forEach(
        (key) =>
            map[key] = (percent(key) * partitioned +
                other.percent(key) * other.partitioned) /
                totalPartitioned);

    return new PartitionMapping(totalPartitioned, totalUnpartitioned, map);
  }

  _keyUnion(PartitionMapping other) =>
      new Set.from(partitionMap.keys)..addAll(other.partitionMap.keys);

  PartitionMapping operator -() =>
      new PartitionMapping(-partitioned, -unpartitioned, partitionMap);

  PartitionMapping operator -(PartitionMapping other) => this + -other;

  bool get isValid =>
      partitioned.isFinite &&
          unpartitioned.isFinite &&
          ((partitionMap.length == 0) ||
              (1.0 - partitionMap.values.fold(0.0, (prev, val) => prev + val)).abs() <
                  0.0001);

  // end <class PartitionMapping>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "partitioned": ebisu_utils.toJson(partitioned),
      "unpartitioned": ebisu_utils.toJson(unpartitioned),
      "partitionMap": ebisu_utils.toJson(partitionMap),
  };

  static PartitionMapping fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PartitionMapping._fromJsonMapImpl(json);
  }

  PartitionMapping._fromJsonMapImpl(Map jsonMap) :
    partitioned = jsonMap["partitioned"],
    unpartitioned = jsonMap["unpartitioned"],
    // partitionMap is Map<String,double>
    partitionMap = ebisu_utils
      .constructMapFromJsonData(
        jsonMap["partitionMap"],
        (value) => value);

  PartitionMapping._copy(PartitionMapping other) :
    partitioned = other.partitioned,
    unpartitioned = other.unpartitioned,
    partitionMap = valueApply(other.partitionMap, (v) =>
      v);

}

class CFlowSequenceSpec {
  CFlowSequenceSpec();

  bool operator==(CFlowSequenceSpec other) =>
    identical(this, other) ||
    dateRange == other.dateRange &&
    paymentFrequency == other.paymentFrequency &&
    initialValue == other.initialValue &&
    growth == other.growth;

  int get hashCode => hash4(dateRange,
    paymentFrequency,
    initialValue,
    growth);

  copy() => new CFlowSequenceSpec()
    ..dateRange = dateRange == null? null : dateRange.copy()
    ..paymentFrequency = paymentFrequency == null? null : paymentFrequency.copy()
    ..initialValue = initialValue == null? null : initialValue.copy()
    ..growth = growth == null? null : growth.copy();

  DateRange dateRange;
  PaymentFrequency paymentFrequency;
  DateValue initialValue;
  RateCurve growth;
  // custom <class CFlowSequenceSpec>

  void visitFlows(DateRange onRange, FlowVisitor visitor) {
    Date currentDate = initialValue.date;
    double value = initialValue.value;
    visitDateRange(dateRange, (Date start, Date end) {
      if (onRange.contains(start)) {
        if (growth != null) {
          value *= growth.scaleFromTo(currentDate, start);
        }
        visitor(start, value);
        currentDate = start;
      }
    }, Frequency.fromJson(paymentFrequency.value));
  }

  TimeSeries expand(DateRange onRange) {
    List<DateValue> result = [];
    var currentValue = initialValue.copy();
    visitFlows(
        onRange,
        (Date date, double flow) => result.add(dateValue(date, flow)));
    return new TimeSeries(result);
  }

  // end <class CFlowSequenceSpec>

  toString() => '(${runtimeType}) => ${ebisu_utils.prettyJsonMap(toJson())}';


  Map toJson() => {
      "dateRange": ebisu_utils.toJson(dateRange),
      "paymentFrequency": ebisu_utils.toJson(paymentFrequency),
      "initialValue": ebisu_utils.toJson(initialValue),
      "growth": ebisu_utils.toJson(growth),
  };

  static CFlowSequenceSpec fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new CFlowSequenceSpec()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    dateRange = DateRange.fromJson(jsonMap["dateRange"]);
    paymentFrequency = PaymentFrequency.fromJson(jsonMap["paymentFrequency"]);
    initialValue = DateValue.fromJson(jsonMap["initialValue"]);
    growth = RateCurve.fromJson(jsonMap["growth"]);
  }
}

/// Create a CFlowSequenceSpec sans new, for more declarative construction
CFlowSequenceSpec
cFlowSequenceSpec() =>
  new CFlowSequenceSpec();

class HoldingKey
  implements Comparable<HoldingKey> {
  HoldingKey(this.accountName, this.holdingName);

  bool operator==(HoldingKey other) =>
    identical(this, other) ||
    accountName == other.accountName &&
    holdingName == other.holdingName;

  int get hashCode => _hashCode != null? _hashCode :
    (_hashCode = hash2(accountName, holdingName));

  int compareTo(HoldingKey other) {
    int result = 0;
    ((result = accountName.compareTo(other.accountName)) == 0) &&
    ((result = holdingName.compareTo(other.holdingName)) == 0);
    return result;
  }

  copy() => new HoldingKey._copy(this);
  final String accountName;
  /// Name of the holding, a real symbol name or possibly a made up representative name
  final String holdingName;
  // custom <class HoldingKey>

  toString() => 'Holding{ account:$accountName, holding:$holdingName }';

  // end <class HoldingKey>

  Map toJson() => {
      "accountName": ebisu_utils.toJson(accountName),
      "holdingName": ebisu_utils.toJson(holdingName),
  };

  static HoldingKey fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new HoldingKey._fromJsonMapImpl(json);
  }

  HoldingKey._fromJsonMapImpl(Map jsonMap) :
    accountName = jsonMap["accountName"],
    holdingName = jsonMap["holdingName"];

  HoldingKey._copy(HoldingKey other) :
    accountName = other.accountName,
    holdingName = other.holdingName,
    _hashCode = other._hashCode;

  int _hashCode;
}

Random _randomJsonGenerator = new Random(0);
// custom <library common>

double DaysPerYear = 365.242199;

final NoCostBasis = new CostBasis(0.0, 0.0);
const String GeneralAccount = "^General";
const String ReserveAccountName = "^Reserve";
final HoldingKey ReserveHolding =
    new HoldingKey(ReserveAccountName, GeneralAccount);

bool isSheltered(AccountType accountType) =>
    accountType == AccountType.ROTH_IRS401K ||
        accountType == AccountType.TRADITIONAL_IRS401K ||
        accountType == AccountType.COLLEGE_IRS529 ||
        accountType == AccountType.TRADITIONAL_IRS401K ||
        accountType == AccountType.HEALTH_SAVINGS_ACCOUNT ?
        true :
        false;

typedef FlowVisitor(Date date, double flow);

// end <library common>
