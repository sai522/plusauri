import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'test_date.dart' as test_date;
import 'test_date_value.dart' as test_date_value;
import 'test_date_range.dart' as test_date_range;
import 'test_finance_mortgage.dart' as test_finance_mortgage;
import 'test_finance_rate_curve.dart' as test_finance_rate_curve;
import 'test_finance_cash_flow.dart' as test_finance_cash_flow;
import 'test_finance_tvm.dart' as test_finance_tvm;
import 'test_finance_curves_attribution.dart' as test_finance_curves_attribution;
import 'test_test_utils.dart' as test_test_utils;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_date.main();
  test_date_value.main();
  test_date_range.main();
  test_finance_mortgage.main();
  test_finance_rate_curve.main();
  test_finance_cash_flow.main();
  test_finance_tvm.main();
  test_finance_curves_attribution.main();
  test_test_utils.main();
}

