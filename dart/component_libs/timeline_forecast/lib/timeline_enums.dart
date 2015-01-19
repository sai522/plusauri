library timeline_forecast.timeline_enums;

// custom <additional imports>
// end <additional imports>

/// Types of display in the timeline
class DisplayType implements Comparable<DisplayType> {
  static const NET_WORTH = const DisplayType._(0);
  static const RESERVES = const DisplayType._(1);
  static const TOTAL_ASSETS = const DisplayType._(2);
  static const TOTAL_LIABILITIES = const DisplayType._(3);
  static const NET_INCOME = const DisplayType._(4);
  static const TOTAL_INCOME = const DisplayType._(5);
  static const TOTAL_EXPENSE = const DisplayType._(6);
  static const INFLATION = const DisplayType._(7);

  static get values => [
    NET_WORTH,
    RESERVES,
    TOTAL_ASSETS,
    TOTAL_LIABILITIES,
    NET_INCOME,
    TOTAL_INCOME,
    TOTAL_EXPENSE,
    INFLATION
  ];

  final int value;

  int get hashCode => value;

  const DisplayType._(this.value);

  copy() => this;

  int compareTo(DisplayType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case NET_WORTH: return "NetWorth";
      case RESERVES: return "Reserves";
      case TOTAL_ASSETS: return "TotalAssets";
      case TOTAL_LIABILITIES: return "TotalLiabilities";
      case NET_INCOME: return "NetIncome";
      case TOTAL_INCOME: return "TotalIncome";
      case TOTAL_EXPENSE: return "TotalExpense";
      case INFLATION: return "Inflation";
    }
    return null;
  }

  static DisplayType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "NetWorth": return NET_WORTH;
      case "Reserves": return RESERVES;
      case "TotalAssets": return TOTAL_ASSETS;
      case "TotalLiabilities": return TOTAL_LIABILITIES;
      case "NetIncome": return NET_INCOME;
      case "TotalIncome": return TOTAL_INCOME;
      case "TotalExpense": return TOTAL_EXPENSE;
      case "Inflation": return INFLATION;
      default: return null;
    }
  }

}

const NET_WORTH = DisplayType.NET_WORTH;
const RESERVES = DisplayType.RESERVES;
const TOTAL_ASSETS = DisplayType.TOTAL_ASSETS;
const TOTAL_LIABILITIES = DisplayType.TOTAL_LIABILITIES;
const NET_INCOME = DisplayType.NET_INCOME;
const TOTAL_INCOME = DisplayType.TOTAL_INCOME;
const TOTAL_EXPENSE = DisplayType.TOTAL_EXPENSE;
const INFLATION = DisplayType.INFLATION;

/// Types of balance displays in the timeline
class BalanceDisplayType implements Comparable<BalanceDisplayType> {
  static const NET_WORTH_BALANCE = const BalanceDisplayType._(0);
  static const TOTAL_ASSETS_BALANCE = const BalanceDisplayType._(1);
  static const TOTAL_LIABILITIES_BALANCE = const BalanceDisplayType._(2);

  static get values => [
    NET_WORTH_BALANCE,
    TOTAL_ASSETS_BALANCE,
    TOTAL_LIABILITIES_BALANCE
  ];

  final int value;

  int get hashCode => value;

  const BalanceDisplayType._(this.value);

  copy() => this;

  int compareTo(BalanceDisplayType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case NET_WORTH_BALANCE: return "NetWorthBalance";
      case TOTAL_ASSETS_BALANCE: return "TotalAssetsBalance";
      case TOTAL_LIABILITIES_BALANCE: return "TotalLiabilitiesBalance";
    }
    return null;
  }

  static BalanceDisplayType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "NetWorthBalance": return NET_WORTH_BALANCE;
      case "TotalAssetsBalance": return TOTAL_ASSETS_BALANCE;
      case "TotalLiabilitiesBalance": return TOTAL_LIABILITIES_BALANCE;
      default: return null;
    }
  }

}

const NET_WORTH_BALANCE = BalanceDisplayType.NET_WORTH_BALANCE;
const TOTAL_ASSETS_BALANCE = BalanceDisplayType.TOTAL_ASSETS_BALANCE;
const TOTAL_LIABILITIES_BALANCE = BalanceDisplayType.TOTAL_LIABILITIES_BALANCE;

/// Types of income/expense displays in the timeline
class FlowDisplayType implements Comparable<FlowDisplayType> {
  static const NET_INCOME_FLOW = const FlowDisplayType._(0);
  static const TOTAL_INCOME_FLOW = const FlowDisplayType._(1);
  static const TOTAL_EXPENSE_FLOW = const FlowDisplayType._(2);

  static get values => [
    NET_INCOME_FLOW,
    TOTAL_INCOME_FLOW,
    TOTAL_EXPENSE_FLOW
  ];

  final int value;

  int get hashCode => value;

  const FlowDisplayType._(this.value);

  copy() => this;

  int compareTo(FlowDisplayType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case NET_INCOME_FLOW: return "NetIncomeFlow";
      case TOTAL_INCOME_FLOW: return "TotalIncomeFlow";
      case TOTAL_EXPENSE_FLOW: return "TotalExpenseFlow";
    }
    return null;
  }

  static FlowDisplayType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "NetIncomeFlow": return NET_INCOME_FLOW;
      case "TotalIncomeFlow": return TOTAL_INCOME_FLOW;
      case "TotalExpenseFlow": return TOTAL_EXPENSE_FLOW;
      default: return null;
    }
  }

}

const NET_INCOME_FLOW = FlowDisplayType.NET_INCOME_FLOW;
const TOTAL_INCOME_FLOW = FlowDisplayType.TOTAL_INCOME_FLOW;
const TOTAL_EXPENSE_FLOW = FlowDisplayType.TOTAL_EXPENSE_FLOW;

/// List of content types, one of which may be displayed in the nav at a time
class NavContentType implements Comparable<NavContentType> {
  static const NET_WORTH_CONTENT = const NavContentType._(0);
  static const TOTAL_ASSETS_CONTENT = const NavContentType._(1);
  static const TOTAL_LIABILITIES_CONTENT = const NavContentType._(2);
  static const NET_INCOME_CONTENT = const NavContentType._(3);
  static const TOTAL_INCOME_CONTENT = const NavContentType._(4);
  static const TOTAL_EXPENSE_CONTENT = const NavContentType._(5);

  static get values => [
    NET_WORTH_CONTENT,
    TOTAL_ASSETS_CONTENT,
    TOTAL_LIABILITIES_CONTENT,
    NET_INCOME_CONTENT,
    TOTAL_INCOME_CONTENT,
    TOTAL_EXPENSE_CONTENT
  ];

  final int value;

  int get hashCode => value;

  const NavContentType._(this.value);

  copy() => this;

  int compareTo(NavContentType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case NET_WORTH_CONTENT: return "NetWorthContent";
      case TOTAL_ASSETS_CONTENT: return "TotalAssetsContent";
      case TOTAL_LIABILITIES_CONTENT: return "TotalLiabilitiesContent";
      case NET_INCOME_CONTENT: return "NetIncomeContent";
      case TOTAL_INCOME_CONTENT: return "TotalIncomeContent";
      case TOTAL_EXPENSE_CONTENT: return "TotalExpenseContent";
    }
    return null;
  }

  static NavContentType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "NetWorthContent": return NET_WORTH_CONTENT;
      case "TotalAssetsContent": return TOTAL_ASSETS_CONTENT;
      case "TotalLiabilitiesContent": return TOTAL_LIABILITIES_CONTENT;
      case "NetIncomeContent": return NET_INCOME_CONTENT;
      case "TotalIncomeContent": return TOTAL_INCOME_CONTENT;
      case "TotalExpenseContent": return TOTAL_EXPENSE_CONTENT;
      default: return null;
    }
  }

}

const NET_WORTH_CONTENT = NavContentType.NET_WORTH_CONTENT;
const TOTAL_ASSETS_CONTENT = NavContentType.TOTAL_ASSETS_CONTENT;
const TOTAL_LIABILITIES_CONTENT = NavContentType.TOTAL_LIABILITIES_CONTENT;
const NET_INCOME_CONTENT = NavContentType.NET_INCOME_CONTENT;
const TOTAL_INCOME_CONTENT = NavContentType.TOTAL_INCOME_CONTENT;
const TOTAL_EXPENSE_CONTENT = NavContentType.TOTAL_EXPENSE_CONTENT;

/// Types of components displayed in annual forecast
class AnnualComponentType implements Comparable<AnnualComponentType> {
  static const BALANCE_SHEET_COMPONENT = const AnnualComponentType._(0);
  static const INCOME_STATEMENT_COMPONENT = const AnnualComponentType._(1);
  static const TAX_SUMMARY_COMPONENT = const AnnualComponentType._(2);
  static const LIQUIDATION_SUMMARY_COMPONENT = const AnnualComponentType._(3);

  static get values => [
    BALANCE_SHEET_COMPONENT,
    INCOME_STATEMENT_COMPONENT,
    TAX_SUMMARY_COMPONENT,
    LIQUIDATION_SUMMARY_COMPONENT
  ];

  final int value;

  int get hashCode => value;

  const AnnualComponentType._(this.value);

  copy() => this;

  int compareTo(AnnualComponentType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case BALANCE_SHEET_COMPONENT: return "BalanceSheetComponent";
      case INCOME_STATEMENT_COMPONENT: return "IncomeStatementComponent";
      case TAX_SUMMARY_COMPONENT: return "TaxSummaryComponent";
      case LIQUIDATION_SUMMARY_COMPONENT: return "LiquidationSummaryComponent";
    }
    return null;
  }

  static AnnualComponentType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "BalanceSheetComponent": return BALANCE_SHEET_COMPONENT;
      case "IncomeStatementComponent": return INCOME_STATEMENT_COMPONENT;
      case "TaxSummaryComponent": return TAX_SUMMARY_COMPONENT;
      case "LiquidationSummaryComponent": return LIQUIDATION_SUMMARY_COMPONENT;
      default: return null;
    }
  }

}

const BALANCE_SHEET_COMPONENT = AnnualComponentType.BALANCE_SHEET_COMPONENT;
const INCOME_STATEMENT_COMPONENT = AnnualComponentType.INCOME_STATEMENT_COMPONENT;
const TAX_SUMMARY_COMPONENT = AnnualComponentType.TAX_SUMMARY_COMPONENT;
const LIQUIDATION_SUMMARY_COMPONENT = AnnualComponentType.LIQUIDATION_SUMMARY_COMPONENT;

// custom <library timeline_enums>
// end <library timeline_enums>
