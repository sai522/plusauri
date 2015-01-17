library plus.test.test_date_value;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
// end <additional imports>

// custom <library test_date_value>
// end <library test_date_value>
main() {
// custom <main>

  group('test_date_value.dart', () {
    group('DateValue', () {
      test('json', () {
        var dv1 = dv(date(2001,1,1), 32);
        expect(DateValue.fromJson(dv1.toJson()), dv1);
      });
      var d1 = date(2001,1,1);
      var d2 = date(2002,1,1);
      test('+', () {
        expect(dv(d1, 100) + dv(d2, 200),
            dv(d2, 300));
      });
      test('isBefore', () {
        expect(dv(d1, 100).isBefore(dv(d1, 100)), false);
        expect(dv(d1, 100).isBefore(dv(d2, 100)), true);
        expect(dv(d2, 100).isBefore(dv(d1, 100)), false);
      });
      test('comparable', () {
        expect(dv(d1, 1).compareTo(dv(d1, 1)), 0);
        expect(dv(d1, 1).compareTo(dv(d2, 1)), -1);
        expect(dv(d2, 1).compareTo(dv(d1, 1)), 1);
        expect(dv(d1, 2).compareTo(dv(d1, 1)), 1);
        expect(dv(d1, 1).compareTo(dv(d1, 3)), -1);
      });
      test('negate', () {
        expect((-dv(d1, 1)).compareTo(dv(d1, -1)), 0);
        });
    });
  });

// end <main>

}
