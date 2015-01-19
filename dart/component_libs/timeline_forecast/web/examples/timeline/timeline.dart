import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';
// custom <additional imports>
export 'package:polymer/init.dart';
import 'dart:html';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/scenario.dart';
import 'package:plus/repository.dart';
//import 'package:portfolio/dbdavidson.dart';
import 'package:timeline_forecast/components/timeline_nav.dart';
import 'package:timeline_forecast/timeline_model.dart';
//import 'package:plus/dbdavidson_dossier.dart';


// end <additional imports>


main() {
  Logger.root.onRecord.listen((LogRecord r) =>
    print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.FINEST;
  initPolymer().run(() {
    Polymer.onReady.then((var _) {
      // custom <timeline main>

      Logger.root.level = Level.WARNING;
      Logger.root.onRecord.listen((LogRecord r) => print(
            "${r.loggerName} [${r.level}]:\t${r.message}"));

      final sw = new Stopwatch()..start();
      //final dossier = myDossier;
      final dossier = repository.dossiers.middleIncome;
      final dr = dateRange(date(2015, 1, 1), date(2066, 1, 1));

      final assumptionModels = {
        'original': dossier.assumptionModel,

        'asset returns halved': new ReturnGeometricShift(0.5).generateScenario(
          dossier, dossier.assumptionModel),

      };

      final timelineComparisonModel =
        new TimelineComparisonModel.fromDossierAssumptionsGrid(dossier, dr,
            assumptionModels);

      final TimelineNav timelineNav = querySelector('#timeline-nav');
      timelineNav.comparisonModel = timelineComparisonModel;

      sw.stop();
      print('Completed => ${sw.elapsedMilliseconds}');

      // end <timeline main>

    });
  });
}

// custom <additional code>
// end <additional code>

