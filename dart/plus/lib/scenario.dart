library plus.scenario;

import 'package:plus/finance.dart';
import 'package:plus/map_utilities.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/models/flow_model.dart';
// custom <additional imports>

// end <additional imports>

part 'src/scenario/holding_value_scenarios.dart';
part 'src/scenario/inflation_scenarios.dart';
part 'src/scenario/longevity_scenarios.dart';
part 'src/scenario/asset_return_scenarios.dart';

abstract class ScenarioGenerator {
  // custom <class ScenarioGenerator>

  AssumptionModel generateScenario(
      Dossier dossier, AssumptionModel assumptionModel);

  // end <class ScenarioGenerator>
}

// custom <library scenario>
// end <library scenario>
