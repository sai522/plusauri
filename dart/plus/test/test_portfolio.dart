library plus.test.test_portfolio;

import 'package:plus/portfolio.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'dart:convert';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
// end <additional imports>

// custom <library test_portfolio>

import 'package:plus/test_utils.dart';

// end <library test_portfolio>
main() {
// custom <main>

  group('Portfolio', () {
    var p = new Portfolio.empty(date(2001,1,1));
    p.addToHolding('IBM', 100.0);
    expect(p.holdingOf('IBM'), 100.0);
  });

  var
    t1 = new Trade(
      date(2001,1,1),
      'FOO',
      BUY,
      100.0,
      20.0),

    t2 = new Trade(
      date(2001,1,2),
      'FOO',
      SELL,
      100.0,
      20.0),

    t3 = new Trade(
      date(2001,1,3),
      'FOO',
      BUY,
      100.0,
      20.0),

    t4 = new Trade(
      date(2001,1,4),
      'FOO',
      BUY,
      100.0,
      20.0);

  group('trade journal', () {
    test('keeps trades sorted and date range', () {
      var tj = tradeJournal([ t2, t1 ]);
      expect(tj.trades[0], t1);
      expect(tj.trades[1], t2);
      expect(tj.dateRange, dateRange(date(2001,1,1), date(2001,1,2).nextDay));

      tj.addTrades([ t4, t3 ]);
      expect(tj.trades[0], t1);
      expect(tj.trades[1], t2);
      expect(tj.trades[2], t3);
      expect(tj.trades[3], t4);
      expect(tj.dateRange, dateRange(date(2001,1,1), date(2001,1,4).nextDay));
    });
  });

  group('PortfolioHistory', () {
    var journal = new TradeJournal([t1,t2,t2,t2,t3,t3,t4,t4]);

    test('fromAllTrades', () {
      var phist = new PortfolioHistory.fromAllTrades(journal);

    });
    test('from portfolio - future trades', () {
      var p = new Portfolio.empty(date(2000,1,1));
      p.createPortfolioHistory(journal);
    });
    test('from portfolio - prior trades', () {
      var p = new Portfolio(date(2002,1,1),
          {
            'FOO': 5000.0,
          });
      p.createPortfolioHistory(journal);
    });
  });

  group('yahoo px resolver', () {
    test('msft', () {
      expect(1,1);
    });
  });

  var startDate = date(2001,1,1);
  nextDay() => startDate = startDate.nextDay;
  nextYear() => startDate = startDate.nextYear;
  buy(qty, price, [ date ]) =>
    new Trade(date == null? nextDay():date, null, BUY, qty, price);
  sell(qty, price, [ date ]) =>
    new Trade(date == null? nextDay():date, null, SELL, qty, price);

  final journals = {
    new TradeJournal([
      buy(1.0, 100.5),
      buy(1.0, 101.5),
      sell(2.0, 100.0)
    ]) : { 'totalGain':-2.0, 'shortTermGain': -2.0, 'longTermGain':0.0 },

    new TradeJournal([
      buy(1.0, 101.5),
      buy(1.0, 100.5),
      sell(2.0, 102.0)
    ]) : { 'totalGain':2.0, 'shortTermGain':2.0, 'longTermGain':0.0 },

    new TradeJournal([
      buy(1.0, 100.5),
      buy(1.0, 101.5, nextYear()),
      sell(2.0, 100.0, nextYear())
    ]) : { 'totalGain':-2.0, 'shortTermGain':0.0, 'longTermGain':-2.0 },

    new TradeJournal([
      buy(1.0, 98.5),
      buy(1.0, 99.5, nextYear()),
      sell(2.0, 100.0, nextYear())
    ]) : { 'totalGain':2.0, 'shortTermGain':0.0, 'longTermGain':2.0 },
  };

  final closers = {
    'lifo': new LIFOLotCloser(),
    'fifo': new FIFOLotCloser(),
    'hifo': new HIFOLotCloser(),
    'low_cost': new LowCostLotCloser(),
  };

  group('cumulative gains', () {
    journals.forEach((journal, expected)
        {
          journal = journal.copy();
          closers.forEach((method, closer) {
                final tta = new TradeTaxAssessor(journal)
                  ..closeLots(closer, null);
                test('$method (stg=>${tta.shortTermGain}, ltg=>${tta.longTermGain})', () {
                  expect(tta.shortTermGain, expected['shortTermGain']);
                  expect(tta.longTermGain, expected['longTermGain']);
                });
              });
        });
  });

  group('AvgCostAccumulator', () {
    test('simple scenario', () {
      // Example from: http://www.investopedia.com/terms/a/averagecostbasismethod.asp
      // These could be validated at http://suzeorman.com/suze-tools/average-cost-basis-analyzer/
      // Buy 1500 @ $20
      final avgCostAccumulator = new AvgCostAccumulator(30000.0, 30000.0);
      // Buy 1000 @ $10
      avgCostAccumulator.markThenBuy(avgCostAccumulator.totalValue*10.0/20.0, 10000.0);
      // Buy 1250 @ $8
      avgCostAccumulator.markThenBuy(avgCostAccumulator.totalValue*8/10, 10000.0);
      // Now sell 1000 @ $19
      double gain = avgCostAccumulator.markThenSell(avgCostAccumulator.totalValue * 19.0/8.0, 19000.0);
      expect(closeEnough(gain, 5666.66666666), true);

      // Extend the example - sell another 1000 @ $22
      gain = avgCostAccumulator.markThenSell(avgCostAccumulator.totalValue * 22/19.0, 22000.0);
      expect(closeEnough(gain, 8666.666666), true);

      // Buy 1000 @ 10
      avgCostAccumulator.markThenBuy(avgCostAccumulator.totalValue * 10.0/22.0, 10000.0);
      // Sell 1000 @ 15
      gain = avgCostAccumulator.markThenSell(avgCostAccumulator.totalValue * 15.0/10.0, 15000.0);
      expect(closeEnough(gain, 2878.78787878), true);
    });

    test('simple scenario - no gains', () {
      final avgCostAccumulator = new AvgCostAccumulator(1000.0, 1000.0, 100.0);
      for(int i=1; i<3; i++) {
        avgCostAccumulator.markThenBuy(avgCostAccumulator.totalValue, 1000.0);
      }
      for(int i=0; i<3; i++) {
        expect(
          closeEnough(
            avgCostAccumulator.markThenSell(avgCostAccumulator.totalValue, 1000.0), 0.0), true);
      }
    });

    test('simple scenario - 10% gains', () {
      final avgCostAccumulator = new AvgCostAccumulator(1000.0, 1000.0, 100.0);
      for(int i=1; i<3; i++) {
        avgCostAccumulator.markThenBuy(avgCostAccumulator.totalValue*1.1, 1000.0);
      }

      double totalGain = avgCostAccumulator
        .markThenSell(avgCostAccumulator.totalValue, avgCostAccumulator.totalValue);

      final expectedGain = ((((1000.0*1.1) + 1000.0)*1.1 + 1000.0) - 3000.0);
      expect(closeEnough(expectedGain, totalGain), true);

    });

});

// end <main>

}
