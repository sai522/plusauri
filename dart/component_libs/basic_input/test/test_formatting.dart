library basic_input.test.test_formatting;

import 'package:basic_input/formatting.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>

// custom <library test_formatting>
// end <library test_formatting>
main() {
// custom <main>

  group('test_formatting.dart', () {
    group('format', () {
      test('pullNum', () {
        expect(pullNum(r"$324,2334x"), 3242334);
        expect(pullNum(r""), null);
        expect(pullNum(r"00.00"), 0);
        expect(pullNum(r"-"), null);
        expect(pullNum(r"-", 0), 0);
        expect(pullNum(r"00.01"), 0.01);
        expect(pullNum(r"0001"), 1);
        expect(pullNum(r"2.34"), 2.34);
        expect(pullNum(r"-2.34"), -2.34);

        expect(pullNum(r"234.555"), 234.555);
        expect(pullNum(r"(234)"), -234);
        expect(pullNum(r"$(234)"), -234);
        expect(pullNum(r"$(234.555)"), -234.555);
        expect(pullNum(r"--234"), null);
        expect(pullNum(r"--234", 0), 0);
        expect(pullNum(r"-234%"), -234);

      });
      test('pullInteger', () {
        expect(pullInteger(r"$324,2334x"), 3242334);
        expect(pullInteger(r""), null);
        expect(pullInteger(r"00.01"), 0);
        expect(pullInteger(r"-$00.5"), -1);
        expect(pullInteger(r"$00.5"), 1);
      });

      test('accountingInt', () {
        expect(accountingInt(2343), r"$2,343");
        expect(accountingInt(-2343), r"$(2,343)");
      });

      test('commifyInt', () {
        expect(commifyInt(2343), "2,343");
        expect(commifyInt(343), "343");
        expect(commifyInt(-343), "(343)");
        expect(commifyInt(-2343), "(2,343)");
      });

      test('commifyNum', () {
        expect(commifyNum(2343), "2,343");
        expect(commifyNum(343), "343");
        expect(commifyNum(-343), "(343)");
        expect(commifyNum(-2343), "(2,343)");
      });

      test('moneyFormat', () {
        expect(moneyFormat(122.3211), r"$122.32");
        expect(moneyFormat(-122.3211), r"$(122.32)");

        expect(moneyFormat(1000000.3211), r"$1,000,000");
        expect(moneyFormat(-1000000.3211), r"$(1,000,000)");

        expect(moneyFormat(122.3211, true), r"$122.32");
        expect(moneyFormat(-122.3211, true), r"$(122.32)");
      });

      test('percentFormat', () {
        expect(percentFormat(0.2322), "23.22%");
        expect(basisPointFormat(0.02322), "232.20 bps");
      });

      test('pullDate', () {
        expect(pullDate("2001-01-05"), new DateTime.utc(2001,1,5));
        expect(pullDate("01/05/2001"), new DateTime.utc(2001,1,5));
        expect(pullDate("1/5/2001"), new DateTime.utc(2001,1,5));
        expect(pullDate("garbage"), null);
        expect(pullDate("garbage", new DateTime.utc(1929,10,29)),
            new DateTime.utc(1929,10,29));
      });

      test('numDigits', () {
        expect(numDigits(3.12), 1);
        expect(numDigits(9.999), 1);
      });

      test('roundTo', () {
        expect(roundToNearest(35.11), 35);
        expect(roundToNearest(35.5), 36);
        expect(roundToCeil(35.5, 2), 36);
        expect(roundToCeil(35.5, 1), 40);
        expect(roundToFloor(35.5, 2), 35);
        expect(roundToFloor(35.5, 1), 30);
        expect(roundToFloor(99.99999, 1), 90);
        expect(roundToFloor(99.99999, 2), 99);
        expect(roundToFloor(100.000, 2), 100);
        expect(roundToFloor(100.0001, 2), 100);
        expect(roundToCeil(100.0001, 2), 110);
        expect(roundToCeil(159.999, 2), 160);
        expect(roundToFloor(159.999, 2), 150);
        expect(roundToNearest(1499999.0), 1500000);
        expect(roundToFloor(1499999.0, 2), 1400000);

        expect(roundToNearest(-35.11), -35);
        expect(roundToFloor(-35.5), -36);
        expect(roundToCeil(-35.5, 3), -35);
        expect(roundToCeil(-35.5, 1), -30);
        expect(roundToFloor(-35.5, 2), -36);
        expect(roundToFloor(-35.5, 3), -36);
        expect(roundToFloor(-999.999, 2), -1000);
        expect(roundToFloor(-99.99999, 1), -100);
        expect(roundToCeil(-99.99999, 2), -99);
        expect(roundToCeil(-100.000, 2), -100);
        expect(roundToFloor(-100.000, 2), -100);
        expect(roundToNearest(-100.0001, 2), -100);
        expect(roundToNearest(-100.0001, 5), -100);
        expect(roundToCeil(-100.0001, 2), -100);
        expect(roundToCeil(-159.999, 2), -150);
        expect(roundToFloor(-159.999, 2), -160);
        expect(roundToNearest(-1499999.0), -1500000);
        expect(roundToCeil(-1499999.0, 4), -1499000);
        expect(roundToFloor(-1499999.0, 4), -1500000);

      });

      test('moneyShortForm', () {
        expect(moneyShortForm(roundToNearest(123212321.1121, 3)), r'$123M');
        expect(moneyShortForm(roundToNearest(-123212321.1121, 3)), r'$(123)M');
        expect(moneyShortForm(roundToFloor(12900000, 2)), r'$12M');
        expect(moneyShortForm(roundToFloor(129900000, 3)), r'$129M');
        expect(moneyShortForm(roundToFloor(12900, 2)), r'$12K');
      });
    });
  });

// end <main>

}
