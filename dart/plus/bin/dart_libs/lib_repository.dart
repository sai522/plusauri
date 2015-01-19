library plus.bin.dart_libs.repository;

import "dart:io";
import "package:path/path.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";
import "../plus_system.dart";

get testLibs => [ testLibrary('test_repository') ];
get lib => library('repository')
  ..imports = [
    'package:plus/date.dart',
    'package:plus/date_value.dart',
    'package:plus/date_range.dart',
    'package:plus/finance.dart',
    'package:plus/models/assumption.dart',
    'package:plus/models/balance_sheet.dart',
    'package:plus/models/common.dart',
    'package:plus/models/dossier.dart',
    'package:plus/models/flow_model.dart',
    'package:plus/models/forecast.dart',
    'package:plus/models/income_statement.dart',
  ]
  ..parts = [
    part('people'),
    part('curves'),
    part('assumptions'),
    part('balance_sheets'),
    part('flow_models'),
    part('dossiers'),
  ]
  ..classes = [
    class_('repository')
  ]
  ..variables = [
    variable('repository')..type = 'Repository'..init = 'new Repository._()'
  ];

get libs => [ lib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
