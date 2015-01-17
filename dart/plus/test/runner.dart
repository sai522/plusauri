import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'test_date.dart' as test_date;
import 'test_date_value.dart' as test_date_value;

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
}

