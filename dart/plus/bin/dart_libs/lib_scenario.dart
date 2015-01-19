library plus.codegen.dart.libs.scenario;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_scenario')
  ..imports.addAll([ 'package:basic_input/formatting.dart' ]);

Library get lib => library('scenario')
  ..imports = [
    'package:plus/models/dossier.dart',
    'package:plus/models/common.dart',
    'package:plus/models/assumption.dart',
    'package:plus/models/flow_model.dart',
    'package:plus/finance.dart',
    'package:plus/map_utilities.dart',
  ]
  ..classes = [
    class_('scenario_generator')
    ..isAbstract = true
  ]
  ..parts = [
    part('holding_value_scenarios')
    ..classes = [
      class_('holding_change_by_factor')
      ..immutable = true
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('factor')..type = 'double',
      ]
    ],
    part('inflation_scenarios')
    ..classes = [
      class_('inflation_geometric_shift')
      ..courtesyCtor = true
      ..allMembersFinal = true
      ..defaultMemberAccess = RO
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('shift')..type = 'double',
        member('shift_expenses')..type = 'bool',
        member('shift_incomes')..type = 'bool',
      ],
      class_('inflation_arithmetic_shift')
      ..courtesyCtor = true
      ..allMembersFinal = true
      ..defaultMemberAccess = RO
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('shift')..type = 'double',
        member('shift_expenses')..type = 'bool',
        member('shift_incomes')..type = 'bool',
      ],
    ],
    part('longevity_scenarios')
    ..classes = [
      class_('extended_life')
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
      ],
      class_('shortened_life')
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
      ]
    ],
    part('asset_return_scenarios')
    ..classes = [
      class_('return_geometric_shift')
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('shift')..classInit = 1.0..ctors = [''],
      ],
      class_('return_arithmetic_shift')
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('shift')..classInit = 1.0..ctors = [''],
      ],
      class_('return_unfavorable_sequence')
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('shift')..classInit = 1.0..ctors = [''],
      ],
      class_('return_favorable_sequence')
      ..implement = [ 'ScenarioGenerator' ]
      ..members = [
        member('shift')..classInit = 1.0..ctors = [''],
      ],
    ],
  ];

get libs => [ lib ];
get testLibs => [ testLib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
