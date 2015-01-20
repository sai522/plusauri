import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'test_binary_search.dart' as test_binary_search;
import 'test_date.dart' as test_date;
import 'test_date_range.dart' as test_date_range;
import 'test_date_value.dart' as test_date_value;
import 'test_finance_mortgage.dart' as test_finance_mortgage;
import 'test_finance_rate_curve.dart' as test_finance_rate_curve;
import 'test_finance_cash_flow.dart' as test_finance_cash_flow;
import 'test_finance_tvm.dart' as test_finance_tvm;
import 'test_finance_curves_attribution.dart'
    as test_finance_curves_attribution;
import 'test_forecast_grid.dart' as test_forecast_grid;
import 'test_forecast.dart' as test_forecast;
import 'test_portfolio.dart' as test_portfolio;
import 'test_repository.dart' as test_repository;
import 'test_scenario.dart' as test_scenario;
import 'test_strategy.dart' as test_strategy;
import 'test_test_utils.dart' as test_test_utils;
import 'test_time_series.dart' as test_time_series;
import 'test_model_assumption.dart' as test_model_assumption;
import 'test_model_balance_sheet.dart' as test_model_balance_sheet;
import 'test_model_common.dart' as test_model_common;
import 'test_model_dossier.dart' as test_model_dossier;
import 'test_model_flow_model.dart' as test_model_flow_model;
import 'test_model_forecast.dart' as test_model_forecast;
import 'test_model_income_statement.dart' as test_model_income_statement;
import 'test_model_liquidation_summary.dart' as test_model_liquidation_summary;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_binary_search.main();
  test_date.main();
  test_date_range.main();
  test_date_value.main();
  test_finance_mortgage.main();
  test_finance_rate_curve.main();
  test_finance_cash_flow.main();
  test_finance_tvm.main();
  test_finance_curves_attribution.main();
  test_forecast_grid.main();
  test_forecast.main();
  test_portfolio.main();
  test_repository.main();
  test_scenario.main();
  test_strategy.main();
  test_test_utils.main();
  test_time_series.main();
  test_model_assumption.main();
  test_model_balance_sheet.main();
  test_model_common.main();
  test_model_dossier.main();
  test_model_flow_model.main();
  test_model_forecast.main();
  test_model_income_statement.main();
  test_model_liquidation_summary.main();
}
