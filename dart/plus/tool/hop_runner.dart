library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop_docgen/hop_docgen.dart';
import 'package:path/path.dart' as path;
import '../test/runner.dart' as runner;

void main(List<String> args) {

  Directory.current = path.dirname(path.dirname(Platform.script.path));

  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  //TODO: Figure this out: addTask('docs', createDocGenTask(_getLibs));
  addTask('analyze_test',
      createAnalyzerTask([
        "test/test_binary_search.dart",
        "test/test_date.dart",
        "test/test_date_range.dart",
        "test/test_date_value.dart",
        "test/test_finance_mortgage.dart",
        "test/test_finance_rate_curve.dart",
        "test/test_finance_cash_flow.dart",
        "test/test_finance_tvm.dart",
        "test/test_finance_curves_attribution.dart",
        "test/test_forecast_grid.dart",
        "test/test_forecast.dart",
        "test/test_portfolio.dart",
        "test/test_repository.dart",
        "test/test_scenario.dart",
        "test/test_strategy.dart",
        "test/test_test_utils.dart",
        "test/test_time_series.dart",
        "test/test_model_assumption.dart",
        "test/test_model_balance_sheet.dart",
        "test/test_model_common.dart",
        "test/test_model_dossier.dart",
        "test/test_model_flow_model.dart",
        "test/test_model_forecast.dart",
        "test/test_model_income_statement.dart",
        "test/test_model_liquidation_summary.dart"
      ]));


  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
