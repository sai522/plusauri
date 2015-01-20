library plus.codegen.dart.libs.plus_system;

import 'root_path.dart';
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import 'package:quiver/iterables.dart';
import 'dart_libs/lib_date.dart' as date;
import 'dart_libs/lib_binary_search.dart' as binary_search;
import 'dart_libs/lib_date_value.dart' as date_value;
import 'dart_libs/lib_date_range.dart' as date_range;
import 'dart_libs/lib_finance.dart' as finance;
import 'dart_libs/lib_forecast.dart' as forecast;
import 'dart_libs/lib_logging.dart' as logging;
import 'dart_libs/lib_portfolio.dart' as portfolio;
import 'dart_libs/lib_repository.dart' as repository;
import 'dart_libs/lib_scenario.dart' as scenario;
import 'dart_libs/lib_strategy.dart' as strategy;
import 'dart_libs/lib_test_utils.dart' as test_utils;
import 'dart_libs/lib_time_series.dart' as time_series;
import 'all_schema.dart' as all_schema;

System plus = () {
  useDartFormatter = true;
  return system('plus')
  ..includeHop = true
  ..generatePubSpec = true
  ..rootPath = rootPath;
}();

void main() {
  binary_search.updateSystem(plus);
  date.updateSystem(plus);
  date_range.updateSystem(plus);
  date_value.updateSystem(plus);
  finance.updateSystem(plus);
  forecast.updateSystem(plus);
  logging.updateSystem(plus);
  portfolio.updateSystem(plus);
  repository.updateSystem(plus);
  scenario.updateSystem(plus);
  strategy.updateSystem(plus);  
  test_utils.updateSystem(plus);
  time_series.updateSystem(plus);
  all_schema.updateSystem(plus);
  
  plus.generate(generateHop : true);
}