library plus.bin.dart_libs.date_value;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_date_value');
Library get lib => library('date_value')
  ..imports = [
    'package:plus/date.dart',
    '"dart:convert" as convert',
    '"dart:math" as math',
  ]
  ..classes = [
    class_('date_value')
    ..opEquals = true
    ..comparable = true
    ..copyable = true
    ..courtesyCtor = true
    ..ctorSansNew = true
    ..members = [
      member('date')..type = 'Date',
      member('value')..type = 'num',
    ],
  ];

get libs => [ lib ];
get testLibs => [ testLib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);