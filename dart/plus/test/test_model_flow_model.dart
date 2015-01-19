library plus.test.test_model_flow_model;

import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>

// custom <library test_model_flow_model>

import 'package:plus/models/income_statement.dart';
import 'package:plus/models/flow_model.dart';

// end <library test_model_flow_model>
main() {
  // custom <main>

  group('test_model_flow_model.dart', () {
    test('hashCode/equality', () {
      var a = new FlowModel({
        'fullTimeJob': new IncomeSpec(
            IncomeType.LABOR_INCOME,
            new FlowSpec('Labor income', 'src', null))
      }, {
        'palimony': new ExpenseSpec(
            ExpenseType.ALIMONY,
            new FlowSpec('Alimony payments', 'src', null))
      });

      var b = new FlowModel({
        'fullTimeJob': new IncomeSpec(
            IncomeType.LABOR_INCOME,
            new FlowSpec('Labor income', 'src', null))
      }, {
        'palimony': new ExpenseSpec(
            ExpenseType.ALIMONY,
            new FlowSpec('Alimony payments', 'src', null))
      });

      expect(a, b);
      expect(identical(a, b), false);
    });
  });

  // end <main>

}
