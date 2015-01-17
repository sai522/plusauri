library plus.bin.dart_libs.date_value;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_date_value');
Library get lib => library('date_value')
  ..imports = [
    'package:plus/date.dart',
    '"dart:convert" as convert',
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

void main() {
  plus
    ..libraries = libs
    ..testLibraries = testLibs
    ..generate( generateHop : false );
}