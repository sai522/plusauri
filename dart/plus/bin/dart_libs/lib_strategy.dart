library plus.bin.dart_libs.strategy;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_strategy')
  ..imports.addAll([ 'package:basic_input/formatting.dart' ]);

Library get lib => library('strategy')
  ..imports = [
    'collection',
    'package:plus/date.dart',
    'package:plus/logging.dart',
    'package:plus/date_value.dart',
    'package:plus/map_utilities.dart',
    'package:plus/models/common.dart',
    'package:plus/models/dossier.dart',
    'package:plus/models/flow_model.dart',
    'package:plus/models/balance_sheet.dart',
    'package:plus/models/assumption.dart',
    'package:plus/models/forecast.dart',
    'package:plus/models/income_statement.dart',
    'package:plus/models/liquidation_summary.dart',
  ]
  ..includeLogger = true
  ..classes = [
   class_('investment_strategy')
   ..isAbstract = true
  ]
  ..parts = [
  ];

get libs => [ lib ];
get testLibs => [ testLib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
