library plus.json_schema.codegen.income_statement;

import 'package:simple_schema/simple_schema.dart';
import 'common.dart';

Package get incomeStatement {

  var pkg = package('income_statement')
  ..defaultRequired = true
  ..imports = [
    common
  ]
  ..enums = [
    ssEnum('income_type',
        [
          'other',
          'interest_income',
          'capital_gain',
          'long_term_capital_gain',
          'short_term_capital_gain',
          'qualified_dividend_income',
          'nonqualified_dividend_income',
          'capital_gain_distribution_income',
          'inheritance_income',
          'pension_income',
          'rental_income',
          'social_security_income',
          'labor_income',
          'lottery_income',
        ]),
    ssEnum('expense_type',
        [
          'other',
          'interest_expense',
          'capital_depreciation',
          'long_term_capital_loss',
          'short_term_capital_loss',
          'living_expense',
          'pension_contribution',
          'auto_expense',
          'college_expense',
          'medical_expense',
          'alimony',
          'palimony',
          'charitable_donation',
          'taxes_federal',
          'taxes_state',
          'taxes_property',
          'debt_mortgage',
          'debt_college',
        ]),
    ssEnum('item_source',
        [
          'balance_sheet',
          'flow_model',
        ]),
  ]
  ..types = [
    schema('income_statement')
    ..properties = [
      prop('year')..init = 0,
      prop('incomes')..type = '{i_e_item}',
      prop('expenses')..type = '{i_e_item}',
    ],
    schema('i_e_item')
    ..properties = [
      prop('source'),
      prop('item_source'),
      prop('details')..type = 'time_series',
    ],
  ];

  return pkg..finalize();
}

main() => incomeStatement
  .schema
  .then((schema) => print(jp(schema.schemaMap)));