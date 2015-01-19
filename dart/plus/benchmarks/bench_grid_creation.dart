library benchmarks.grid_creation;

import 'package:benchmark_harness/benchmark_harness.dart';
// custom <additional imports>

import 'package:plus/date_range.dart';
import 'package:plus/repository.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/forecast.dart';

// end <additional imports>

class BenchGridCreation extends BenchmarkBase {
  BenchGridCreation() : super('GridCreation');

  // custom <class BenchGridCreation>

  Dossier _dossier = repository.dossiers.middleIncome;
  ForecastGrid _forecastGrid;

  int _count = 0;

  void run() {
    _forecastGrid = new ForecastGrid.fromDossier(_dossier,
        new YearRange(2015, 2015+80));
    _count++;
  }

  static void main() {
    new BenchGridCreation().report();
  }

  void setup() { }

  void teardown() {
    //print('Ran $_count iterations: $_forecastGrid');
    print('Ran $_count iterations');
  }

  // end <class BenchGridCreation>
}

// custom <library bench_grid_creation>
// end <library bench_grid_creation>
main() {
  BenchGridCreation.main();
}

