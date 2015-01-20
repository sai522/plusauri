library plus.finance;

import 'dart:convert' as convert;
import 'dart:math';
import 'package:collection/equality.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/map_utilities.dart';
import 'package:quiver/core.dart';
// custom <additional imports>

import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;

// end <additional imports>

part 'src/finance/cash_flow.dart';
part 'src/finance/rate_curve.dart';
part 'src/finance/curves_attribution.dart';
part 'src/finance/tvm.dart';
part 'src/finance/mortgage.dart';

/// Breakdown of small, mid and large cap
class CapitalizationType implements Comparable<CapitalizationType> {
  static const SMALL_CAP = const CapitalizationType._(0);
  static const MID_CAP = const CapitalizationType._(1);
  static const LARGE_CAP = const CapitalizationType._(2);

  static get values => [SMALL_CAP, MID_CAP, LARGE_CAP];

  final int value;

  int get hashCode => value;

  const CapitalizationType._(this.value);

  copy() => this;

  int compareTo(CapitalizationType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case SMALL_CAP:
        return "SmallCap";
      case MID_CAP:
        return "MidCap";
      case LARGE_CAP:
        return "LargeCap";
    }
    return null;
  }

  static CapitalizationType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "SmallCap":
        return SMALL_CAP;
      case "MidCap":
        return MID_CAP;
      case "LargeCap":
        return LARGE_CAP;
      default:
        return null;
    }
  }

  int toJson() => value;
  static CapitalizationType fromJson(int v) {
    return v == null ? null : values[v];
  }
}

const SMALL_CAP = CapitalizationType.SMALL_CAP;
const MID_CAP = CapitalizationType.MID_CAP;
const LARGE_CAP = CapitalizationType.LARGE_CAP;

/// Breakdown by style
class InvestmentStyle implements Comparable<InvestmentStyle> {
  static const VALUE_INVESTMENT = const InvestmentStyle._(0);
  static const BLEND_INVESTMENT = const InvestmentStyle._(1);
  static const GROWTH_INVESTMENT = const InvestmentStyle._(2);

  static get values => [VALUE_INVESTMENT, BLEND_INVESTMENT, GROWTH_INVESTMENT];

  final int value;

  int get hashCode => value;

  const InvestmentStyle._(this.value);

  copy() => this;

  int compareTo(InvestmentStyle other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case VALUE_INVESTMENT:
        return "ValueInvestment";
      case BLEND_INVESTMENT:
        return "BlendInvestment";
      case GROWTH_INVESTMENT:
        return "GrowthInvestment";
    }
    return null;
  }

  static InvestmentStyle fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "ValueInvestment":
        return VALUE_INVESTMENT;
      case "BlendInvestment":
        return BLEND_INVESTMENT;
      case "GrowthInvestment":
        return GROWTH_INVESTMENT;
      default:
        return null;
    }
  }

  int toJson() => value;
  static InvestmentStyle fromJson(int v) {
    return v == null ? null : values[v];
  }
}

const VALUE_INVESTMENT = InvestmentStyle.VALUE_INVESTMENT;
const BLEND_INVESTMENT = InvestmentStyle.BLEND_INVESTMENT;
const GROWTH_INVESTMENT = InvestmentStyle.GROWTH_INVESTMENT;

/// Breakdown by stock/bond/cash/other
class AllocationType implements Comparable<AllocationType> {
  static const STOCK_ALLOCATION = const AllocationType._(0);
  static const BOND_ALLOCATION = const AllocationType._(1);
  static const CASH_ALLOCATION = const AllocationType._(2);
  static const OTHER = const AllocationType._(3);

  static get values =>
      [STOCK_ALLOCATION, BOND_ALLOCATION, CASH_ALLOCATION, OTHER];

  final int value;

  int get hashCode => value;

  const AllocationType._(this.value);

  copy() => this;

  int compareTo(AllocationType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case STOCK_ALLOCATION:
        return "StockAllocation";
      case BOND_ALLOCATION:
        return "BondAllocation";
      case CASH_ALLOCATION:
        return "CashAllocation";
      case OTHER:
        return "Other";
    }
    return null;
  }

  static AllocationType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "StockAllocation":
        return STOCK_ALLOCATION;
      case "BondAllocation":
        return BOND_ALLOCATION;
      case "CashAllocation":
        return CASH_ALLOCATION;
      case "Other":
        return OTHER;
      default:
        return null;
    }
  }

  int toJson() => value;
  static AllocationType fromJson(int v) {
    return v == null ? null : values[v];
  }
}

const STOCK_ALLOCATION = AllocationType.STOCK_ALLOCATION;
const BOND_ALLOCATION = AllocationType.BOND_ALLOCATION;
const CASH_ALLOCATION = AllocationType.CASH_ALLOCATION;
const OTHER = AllocationType.OTHER;

// custom <library finance>

// end <library finance>
