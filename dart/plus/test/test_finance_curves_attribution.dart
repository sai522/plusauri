library plus.test.test_finance_curves_attribution;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

//import 'package:plus/models/assumption.dart';
import 'package:plus/date_range.dart';

// end <additional imports>

// custom <library test_finance_curves_attribution>

class HoldingReturnType implements Comparable<HoldingReturnType> {
  static const INTEREST = const HoldingReturnType._(0);
  static const QUALIFIED_DIVIDEND = const HoldingReturnType._(1);
  static const UNQUALIFIED_DIVIDEND = const HoldingReturnType._(2);
  static const CAPITAL_GAIN_DISTRIBUTION = const HoldingReturnType._(3);
  static const CAPITAL_APPRECIATION = const HoldingReturnType._(4);

  static get values => [
    INTEREST,
    QUALIFIED_DIVIDEND,
    UNQUALIFIED_DIVIDEND,
    CAPITAL_GAIN_DISTRIBUTION,
    CAPITAL_APPRECIATION
  ];

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

// end <library test_finance_curves_attribution>
main() {
// custom <main>

  group('test_finance_curves_attribution.dart', () {
    final d1 = date(2001, 1, 1),
        d2 = date(2020, 1, 1);
    final r1 = 0.03;
    final rc1 = rateCurve([dv(date(1900, 1, 1), r1)]);
    final dr = dateRange(d1, d2);

    group('curves_attribution', () {
      test('with no curves', () {
        var curvesAttribution = new CurvesAttribution({});
        var attribution = curvesAttribution.scaleOnIntervals(dr);
        expect(attribution.totalValue(300.0), 300);
        expect(attribution.contributionDelta('foo', 300.0), 0);
      });

      test('with one curve', () {
        var curvesAttribution =
            new CurvesAttribution({HoldingReturnType.QUALIFIED_DIVIDEND: rc1});
        var attribution = curvesAttribution.scaleOnIntervals(dr);
        var expected = rc1.scaleFromTo(d1, d2) - 1.0;
        expect(closeEnough(attribution.contributionDelta(
            HoldingReturnType.QUALIFIED_DIVIDEND, 1.0), expected), true);
      });

      test('with two curves', () {
        var r1 = 0.03;
        var r2 = 0.03;
        var curve1 = rateCurve([dv(d1, r1)]);
        var curve2 = rateCurve([dv(d1, r2)]);
        final totalCurve = rateCurve([dv(date(1900, 1, 1), r1 + r2)]);

        var curvesAttribution = new CurvesAttribution({
          HoldingReturnType.QUALIFIED_DIVIDEND: curve1,
          HoldingReturnType.UNQUALIFIED_DIVIDEND: curve2,
        });

        // If you add the curves and scale with that it overstates the interplay
        // of compounding
        var excessiveCompounding = totalCurve.scaleFromTo(d1, d2);

        // If you treat them separately and scale them, then sum them
        // it understates value since there is no compounding
        var v1Net = curve1.scaleFromTo(d1, d2) - 1.0;
        var v2Net = curve2.scaleFromTo(d1, d2) - 1.0;
        double grossSeparate = v1Net + v2Net + 1.0;

        var attribution = curvesAttribution.scaleOnIntervals(dr);
        expect(excessiveCompounding > attribution.totalValue(), true);
        expect(attribution.totalValue() > grossSeparate, true);
      });
    });

    test('with mixed signs', () {
      expect(print('TODO: add expectations'), null);
      final negativeYear = date(2002, 1, 1);
      final positiveYear = date(2003, 1, 1);
      final curvesAttribution = new CurvesAttribution({
        HoldingReturnType.QUALIFIED_DIVIDEND: rateCurve([dv(d1, 0.015)]),
        HoldingReturnType.UNQUALIFIED_DIVIDEND: rateCurve([dv(d1, 0.01)]),
        HoldingReturnType.CAPITAL_APPRECIATION: rateCurve(
            [dv(d1, 0.04), dv(negativeYear, -0.04), dv(positiveYear, 0.04)])
      });

      final attribution = curvesAttribution
          .scaleOnIntervals(dateRange(negativeYear, positiveYear));

      double total = 0.0;
      [
        HoldingReturnType.QUALIFIED_DIVIDEND,
        HoldingReturnType.UNQUALIFIED_DIVIDEND,
        HoldingReturnType.CAPITAL_APPRECIATION
      ].forEach((HoldingReturnType ht) {
        print('\t$ht => ${attribution.contributionDelta(ht, 1.0)}');
        total += attribution.contributionDelta(ht, 1.0);
      });
      print('Total ${1.0+total} and ${attribution.totalValue()}');
    });
  });

// end <main>

}
