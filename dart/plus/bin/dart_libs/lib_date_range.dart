library plus.bing.dart_libs.date_range;

import "dart:io";
import "package:path/path.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_date_range');
Library get lib => library('date_range')
  ..imports = [
    'package:plus/date.dart',
  ]
  ..classes = [
    class_('year_range')
    ..defaultMemberAccess = RO
    ..ctorCallsInit = true
    ..immutable = true
    ..allMembersFinal = true
    ..members = [
      member('start')..type = 'int',
      member('end')..type = 'int',
    ],
    class_('date_range')
    ..defaultMemberAccess = IA
    ..jsonSupport = true
    ..ctorSansNew = true
    ..opEquals = true
    ..comparable = true
    ..copyable = true
    ..courtesyCtor = true
    ..ctorCustoms = ['']
    ..members = [
      member('start')..type = 'Date'..access = RO,
      member('end')..type = 'Date'..access = RO,
    ],
    class_('interval_date_range')
    ..defaultMemberAccess = RO
     ..courtesyCtor = true
    ..allMembersFinal = true
    ..copyable = true
    ..opEquals = true
    ..members = [
      member('start')..type = 'Date',
      member('end')..type = 'Date',
      member('frequency')..type = 'Frequency',
      member('date_ranges')..type = 'List<DateRange>'
    ],
  ];

get libs => [ lib ];
get testLibs => [ testLib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);