library plus.test.test_forecast;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/forecast.dart';
import 'package:plus/models/balance_sheet.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/finance.dart';
import 'package:plus/map_utilities.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/forecast.dart';
import 'package:plus/repository.dart';

// end <additional imports>

// custom <library test_forecast>
// end <library test_forecast>
main() {
// custom <main>

  var reinvested = new DistributionBreakdown(0.01, 0.02, 0.03, 0.0);
  var distributed = new DistributionBreakdown(0.04, 0.05, 0.06, 0.0);
  var divSum = new DistributionSummary(distributed, reinvested);

  group('test_model_balance_sheet.dart', () {
    group('DistributionSummary', () {
      test('operator +=', () {
        var a = new DistributionBreakdown(1.0, 2.0, 3.0, 4.0);
        var original = a;
        var b = new DistributionBreakdown(3.0, 2.0, 1.0, 0.0);
        a.plusEqual(b);
        expect(a.qualified, 4.0);
        expect(a.unqualified, 4.0);
        expect(a.capitalGainDistribution, 4.0);
        expect(a.interest, 4.0);
      });
    });
    group('DistributionSummary', () {
      test('operator+', () {
        expect((new DistributionSummary(reinvested, distributed)) +
                (new DistributionSummary(reinvested, distributed)),
            new DistributionSummary(
                reinvested + reinvested, distributed + distributed));
      });

      test('operator-', () {
        expect(-(new DistributionSummary(reinvested, distributed)),
            new DistributionSummary(-reinvested, -distributed));
      });
    });

    group('PeriodBalance', () {
      test('operator+', () {
        expect((new PeriodBalance.courtesy(
                    dv(date(2001, 1, 1), 1.0), dv(date(2002, 1, 1), 2.0))) +
                (new PeriodBalance.courtesy(
                    dv(date(2001, 1, 1), 1.0), dv(date(2002, 1, 1), 2.0))),
            new PeriodBalance.courtesy(
                dv(date(2001, 1, 1), 2.0), dv(date(2002, 1, 1), 4.0)));
      });
    });

    group('PeriodBalance', () {
      var apb = new PeriodBalance.courtesy(
          dv(date(2001, 1, 1), 1.0), dv(date(2002, 1, 1), 2.0));

      test('operator+=', () {
        var pb = apb.copy();
        pb += pb;
        expect(pb.startValue, 2.0);
        expect(pb.endValue, 4.0);
      });

      test('operator-=', () {
        var pb = apb.copy();
        pb -= pb;
        expect(pb.startValue, 0.0);
        expect(pb.endValue, 0.0);
      });

      test('operator-', () {
        var pb = apb.copy();
        expect(-pb, new PeriodBalance.courtesy(
            dv(date(2001, 1, 1), -1.0), dv(date(2002, 1, 1), -2.0)));
      });
    });

    group('HoldingPeriodBalance', () {
      final startDate = date(2001, 1, 1);
      final NoCostBasis = new PeriodBalance.empty(2001);
      var ds = divSum;
      var pb = new PeriodBalance.courtesy(
          dv(startDate, 1.0), dv(date(2002, 1, 1), 2.0));
      var ipm = new InstrumentPartitionMappings.empty().newValue(2.0);
      var details = {HoldingReturnType.INTEREST: 0.02};
      var hpb = new HoldingPeriodBalance(
          HoldingType.CASH, pb, ds, NoCostBasis, 0.0, ipm, details, 0.0);
      test('operator-', () {
        expect(-hpb, new HoldingPeriodBalance(HoldingType.CASH, -pb, -ds,
            NoCostBasis, 0.0, -ipm, valueApply(details, (v) => -v), 0.0));
      });
      test('operator-(other)', () {
        var zero = hpb - hpb;
        expect(zero, new HoldingPeriodBalance(HoldingType.CASH, pb - pb,
            ds - ds, NoCostBasis, 0.0, ipm - ipm,
            valueApply(details, (v) => 0.0), 0.0));
      });
      test('operator-=', () {
        var zero = hpb.copy();
        zero -= hpb;
        expect(zero, new HoldingPeriodBalance(HoldingType.CASH, pb - pb,
            ds - ds, NoCostBasis, 0.0, ipm - ipm,
            valueApply(details, (v) => 0.0), 0.0));
      });
      test('operator+', () {
        final twice = hpb + hpb;
        expect(twice.periodBalance, hpb.periodBalance + hpb.periodBalance);
        expect(twice.distributionSummary,
            hpb.distributionSummary + hpb.distributionSummary);
        twice.growthDetails.forEach(
            (k, v) => expect(closeEnough(v, 2 * hpb.growthDetails[k]), true));
      });
      test('operator+=', () {
        var hpbCopy = hpb.copy();
        hpbCopy += hpbCopy;
        expect(hpbCopy, hpb + hpb);
      });

      test('hpb not changed', () {
        expect(hpb.periodBalance.start, dv(date(2001, 1, 1), 1.0));
        expect(hpb.periodBalance.end, dv(date(2002, 1, 1), 2.0));
        expect(hpb.growthDetails, {HoldingReturnType.INTEREST: .02});
        expect(hpb.distributionSummary, divSum);
      });
    });
  });

  group('test_forecast.dart', () {
    group('forecaster', () {});
  });

// end <main>

}
