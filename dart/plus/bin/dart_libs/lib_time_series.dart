library plus.bin.dart_libs.time_series;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

var _commonImports = [
  'math',
  'package:plus/date.dart',
  'package:plus/date_value.dart',
  'package:plus/date_range.dart',
  'package:plus/test_utils.dart',
];

List<Library> get testLibs =>[
  testLibrary('test_time_series')
  ..imports.addAll(_commonImports),
];

Library get lib => library('time_series')
  ..includeLogger = true
  ..imports.addAll([
    'package:plus/binary_search.dart',
    'package:plus/date.dart',
    '"package:plus/date_value.dart" hide firstOnOrBefore',
    '"package:plus/date_value.dart" as dv show firstOnOrBefore',
    'package:plus/date_range.dart',
    "'dart:convert' as convert",
  ])
  ..classes = [
    class_('time_series')
    ..ctorCustoms = ['']
    ..defaultMemberAccess = RO
    ..copyable = true
    ..jsonSupport = false
    ..courtesyCtor = true
    ..ctorSansNew = true
    ..opEquals = true
    ..members = [
      member('data')
      ..isFinal = true
      ..type = 'List<DateValue>',
    ],
  ];

get libs => [ lib ];

updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
