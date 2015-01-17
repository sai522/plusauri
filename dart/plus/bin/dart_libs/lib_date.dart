library plus.bin.dart_libs.date;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_date');
Library get lib => library('date')
  ..imports = [
    'math'
  ]
  ..enums = [
    enum_('frequency')
    ..doc = 'Frequency, for example of payments, for IntervalDateRanges'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('once'), id('monthly'), id('semiannual'), id('annual')
    ]
  ]
  ..classes = [
    class_('date')
    ..defaultMemberAccess = IA
    ..opEquals = true
    ..comparable = true
    ..members = [
      member('date_time')..isFinal = true
      ..type = 'DateTime'..access = RO,
    ],
  ];

get libs => [ lib ];
get testLibs => [ testLib ];

void main() {
  plus
    ..libraries = [ lib ]
    ..testLibraries = [ testLib ]
    ..generate( generateHop : false );
}