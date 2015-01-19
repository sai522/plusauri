library benchmarks.grid_timeline_creation;

import 'package:benchmark_harness/benchmark_harness.dart';
// custom <additional imports>

import 'package:plus/date_range.dart';
import 'package:plus/forecast.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/repository.dart';
import 'package:timeline_forecast/timeline_model.dart';

// end <additional imports>

class BenchGridTimelineCreation extends BenchmarkBase {
  BenchGridTimelineCreation() : super('GridTimelineCreation');

  // custom <class BenchGridTimelineCreation>

  Dossier _dossier = repository.dossiers.middleIncome;
  ForecastGrid _forecastGrid;
  YearRange _yearRange = new YearRange(2015, 2015 + 80);

  int _count = 0;

  void run() {
    final ITimelineModel tlm =
        new GridTimelineModel(_forecastGrid, curves.inflation);
    for (int year = _yearRange.start; year < _yearRange.end; year++) {
      final IAnnualForecastModel annualForecastModel =
          tlm.annualForecastModel('Awesome Model $year', year);

      final ism = annualForecastModel.incomeStatementModel;

      ism.visitIncomes((String name, double amount) {
        //print('$year Inc $name, $amount');
      });

      ism.visitExpenses((String name, double amount) {
        //print('$year Exp $name, $amount');
      });

      final bsm = annualForecastModel.balanceSheetModel;


      bsm.visitAssets((String name, double startValue, double endValue) {
        //print('$name, $startValue, $endValue');
      });

      bsm.visitLiabilities((String name, double startValue, double endValue) {

      });


      for (int i = 0; i < 1; i++) {
        bsm.visitAccounts((String accountName, int numHoldings) {
          final hpb = bsm.createAccountHoldingPeriodBalance(accountName);
          bsm.visitAccountOtherHoldings(
              accountName,
              (HoldingKey hk, double startValue, double endValue) {
            //        print('<OTHER>: $hk $startValue, $endValue');


            //print("Doing $accountName, $hk");
            bsm.createHoldingPeriodBalance(accountName, hk.holdingName);


          });
          bsm.visitAccountHoldings(
              accountName,
              (HoldingKey hk, double startValue, double endValue) {
            //        print('<OTHER>: $hk $startValue, $endValue');
          });

        });
      }

      final lsm = annualForecastModel.liquidationSummaryModel;
      lsm.visitCredits(
          (HoldingKey holdingKey, String incomeName, double amount, double balance) {

            //print('$year - $holdingKey credited $amount from $incomeName $balance');
      });

      lsm.visitDebits(
          (HoldingKey holdingKey, String expenseName, double amount, double balance) {

            //print('$year - $holdingKey debited $amount from $expenseName $balance');
      });

      if (false) {
        print('Total Holdings: ${bsm.totalHoldings}');
        print('Total NonHoldings: ${bsm.totalNonHoldingAssets}');
        print('Total Liabilities: ${bsm.totalLiabilities}');
      }
    }
    _count++;
  }

  static void main() {
    new BenchGridTimelineCreation().report();
  }

  void setup() {
    _dossier = myDossier;
    _forecastGrid =
        new ForecastGrid.fromDossier(_dossier, _yearRange, trackDetails: true);
  }

  void teardown() {
    print('Ran $_count iterations');
  }

  // end <class BenchGridTimelineCreation>
}

// custom <library bench_grid_timeline_creation>
// end <library bench_grid_timeline_creation>
main() {
  BenchGridTimelineCreation.main();
}

