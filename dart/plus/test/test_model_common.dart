library plus.test.test_model_common;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/models/common.dart';
import 'package:plus/repository.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/time_series.dart';
import 'package:plus/test_utils.dart';

// end <additional imports>

// custom <library test_model_common>
// end <library test_model_common>
main() {
// custom <main>

  group('test_model_common.dart', () {
    var partTimeJob = repository.incomeSpecs.partTimeJob;
    var middleClassLifeGross = repository.expenseSpecs.middleClassLifeGross;
    //print(partTimeJob);
    //print(middleClassLifeGross);
    test('CFlowSequenceSpec expand - frequency once', () {
      var spec = (cFlowSequenceSpec()
          ..dateRange = dateRange(date(2000, 1, 1), date(2000, 1, 1))
          ..paymentFrequency = PaymentFrequency.ONCE
          ..initialValue = dateValue(date(2000, 1, 1), 1.0));

      expect(
          spec.expand(dateRange(date(2000, 1, 2), date(2011, 1, 1))),
          timeSeries([]));
      expect(
          spec.expand(dateRange(date(2000, 1, 1), date(2011, 1, 1))),
          timeSeries([dateValue(date(2000, 1, 1), 1.0)]));
    });

    test('CFlowSequenceSpec expand - frequency monthly - no growth', () {
      var spec = (cFlowSequenceSpec()
          ..dateRange = dateRange(date(2000, 1, 1), date(2001, 1, 1))
          ..paymentFrequency = PaymentFrequency.MONTHLY
          ..initialValue = dateValue(date(2000, 1, 1), 1.0));

      expect(
          spec.expand(dateRange(date(2000, 1, 1), date(2000, 3, 1))),
          timeSeries(
              [dateValue(date(2000, 1, 1), 1.0), dateValue(date(2000, 2, 1), 1.0),]));

      expect(
          spec.expand(dateRange(date(2000, 1, 1), date(2020, 1, 1))).length,
          12);
    });

    group('PartitionMapping basics', () {
      test('Invalid parition', () {
        expect(() => new PartitionMapping.validated(1000.0, 0.0, {
          'a': 0.5,
          'b': 0.6
        }), throwsA(new isInstanceOf<ArgumentError>()));
      });
      final p1 = {
        "foo": .3,
        "bar": .2,
        "goo": .5
      };
      final p2 = {
        "foo": .5,
        "bar": .2,
        "goo": .3
      };
      final p3 = {
        "foo": .5,
        "bar": .2,
        "goo": .3,
        "moo": 0.0
      };

      final pm1 = new PartitionMapping.validated(1000.0, 0.0, p1);
      final pm2 = new PartitionMapping.validated(1000.0, 0.0, p2);
      final pm3 = new PartitionMapping.validated(1000.0, 0.0, p3);
      test('sum does weighted addition', () {
        final sum = pm1 + pm2;
        expect(sum.percent('foo'), .4);
        expect(sum.percent('bar'), .2);
        expect(sum.percent('goo'), .4);
        expect(sum.percent('moo'), 0.0);
      });

      test('sum allows distinct key sets', () {
        final sum = pm1 + pm3;
        expect(sum.percent('moo'), 0.0);
        expect(sum.percent('foo'), .4);
      });

      test('sum tracks unpartitioned', () {
        final pm1 = new PartitionMapping(0.0, 1000.0, p1);
        final pm2 = new PartitionMapping(0.0, 1000.0, p2);
        final sum = pm1 + pm2;
        expect(sum.percent('foo'), 0.0);
        expect(sum.partitioned, 0.0);
        expect(sum.unpartitioned, 2000.0);
      });

    });

    /*
    group('ValuePartitions operator+', () {
      final ip1 = new InstrumentPartitions(
          new AllocationPartition(0.6, 0.1, 0.2, 0.1),
          new InvestmentStylePartition(0.2, 0.5, 0.3),
          new CapitalizationPartition(0.2, 0.3, 0.5));

      final ip2 = new InstrumentPartitions(
          new AllocationPartition(0.1, 0.1, 0.2, 0.6),
          new InvestmentStylePartition(0.3, 0.5, 0.2),
          new CapitalizationPartition(0.5, 0.3, 0.2));

      final vip1 = new ValuePartitions.courtesy(1000.0, ip1);
      final vip2 = new ValuePartitions.courtesy(1000.0, ip2);

      test('ValuePartitions operator+', () {
        {
          // Adding the same value of instrument should keep the same partition
          final both = vip1 + vip1;
          expect(vip1.instrumentPartitions, both.instrumentPartitions);
        }
        {
          final instrumentPartitions = (vip1 + vip2).instrumentPartitions;
          final capitalizationPartition = instrumentPartitions.capitalizationPartition;
          final investmentStylePartition = instrumentPartitions.investmentStylePartition;
          final allocationPartition = instrumentPartitions.allocationPartition;
          expect(capitalizationPartition.smallCap, (.5+.2)/2);
          expect(capitalizationPartition.midCap, (.3+.3)/2);
          expect(capitalizationPartition.largeCap, (.5+.2)/2);
          expect(investmentStylePartition.value, (.2+.3)/2);
          expect(investmentStylePartition.blend, (.5+.5)/2);
          expect(investmentStylePartition.growth, (.3+.2)/2);
          expect(allocationPartition.stock, (.6+.1)/2);
          expect(allocationPartition.bond, (.1+.1)/2);
          expect(allocationPartition.cash, (.2+.2)/2);
          expect(allocationPartition.other, (.1+.6)/2);
        }

        {
          final empty1 = new ValuePartitions.courtesy(1000.0,
              new InstrumentPartitions.empty());
          final empty2 = new ValuePartitions.courtesy(1000.0,
              new InstrumentPartitions.empty());
          final sum = empty1+empty2;
        }
      });
    });
    */

    test('CFlowSequenceSpec expand - frequency monthly - with growth', () {
      var spec = (cFlowSequenceSpec()
          ..dateRange = dateRange(date(2000, 1, 1), date(2001, 1, 1))
          ..paymentFrequency = PaymentFrequency.MONTHLY
          ..initialValue = dateValue(date(2000, 1, 1), 1.0)
          ..growth = rateCurve([dateValue(date(1900, 1, 1), 0.03)]));

      var expanded = spec.expand(dateRange(date(2000, 1, 1), date(2000, 6, 1)));
      expect(expanded[0], spec.initialValue);
      var current = dateValue(spec.dateRange.start, 1.0);
      for (int i = 0; i < 5; i++) {
        expect(expanded[i].date, current.date);
        expect(closeEnough(expanded[i].value, current.value), true);

        var nextDate = advanceDate(MONTHLY, current.date);

        current =
            dateValue(nextDate, spec.growth.revalueOn(spec.initialValue, nextDate));
      }

      expect(
          spec.expand(dateRange(date(2000, 1, 1), date(2020, 1, 1))).length,
          12);
    });

  });


// end <main>

}
