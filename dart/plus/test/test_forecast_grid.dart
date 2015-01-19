library plus.test.test_forecast_grid;

import 'dart:math';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/forecast.dart';
import 'package:plus/models/balance_sheet.dart';
import 'package:plus/test_utils.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:logging/logging.dart';
import 'package:plus/logging.dart';

// end <additional imports>

// custom <library test_forecast_grid>

import 'package:plus/repository.dart';

// end <library test_forecast_grid>
main() {
// custom <main>

  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));

  group('grid creation', () {
    final dossier = repository.dossiers.middleIncome;
    //print(dossier);

    //    print(dossier);
    final grid = new ForecastGrid.fromDossier(
        dossier,
        new YearRange(2014, 2084),
        trackDetails: true);
  });

// end <main>

}

