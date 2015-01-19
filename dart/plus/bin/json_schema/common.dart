library plus.json_schema.codegen.common;

import 'package:simple_schema/simple_schema.dart';

Package get common {

  var pkg = package('common')
  ..defaultRequired = true
  ..enums = [
    ssEnum('account_type',
        [
          'other',
          'roth_irs401k',
          'traditional_irs401k',
          'college_irs529',
          'traditional_ira',
          'investment',
          'brokerage',
          'checking',
          'health_savings_account',
          'savings',
          'money_market',
          'mattress',
        ]),
    ssEnum('asset_type',
        [
          'other',
          'investment',
          'primary_residence',
          'family_property',
          'financial_instrument',
          'automobile',
          'life_insurance_policy',
          'company_stock_option',
          'savings',
          'college_savings',
          'retirement_savings',
          'cash',
          'rental_property',
        ]),
    ssEnum('liability_type',
        [
          'other',
          'mortgage',
          'auto_loan',
          'college_debt',
          'credit_card_debt',
        ]),
    ssEnum('holding_type',
        [
          'other',
          'stock',
          'bond',
          'cash',
          'blend',
        ]),
    ssEnum('interpolation_type',
        [ 'linear', 'step', 'cubic' ]),
    ssEnum('payment_frequency',
        [
          'once',
          'monthly',
          'semiannual',
          'annual',
        ]),
    ssEnum('tax_category',
        [
          'labor_income',
          'interest_income',
          'qualified_dividend_income',
          'unqualified_dividend_income',
          'short_term_capital_gain',
          'long_term_capital_gain',
          'social_security_income',
          'pension_income',
          'other_ordinary_income',
          'inheritance',
          'rental_income',
          'property_value',
        ]),
    ssEnum('tax_type',
        [
          'ordinary_income',
          'qualified_dividend',
          'long_term_capital_gain',
          'short_term_capital_gain',
          'inheritance',
          'medicare',
          'social_security',
          'property',
        ]),
    ssEnum('taxing_authority',
        [
          'federal',
          'state',
        ]),
  ]
  ..types = [
    // Defined elsewhere - this is really only needed to register the type name
    // so the shortcut of a prop without a typespec gleans the type associated
    // with the name. (e.g. prop('date_range') will assume type date_range if it
    // is known - here we make it known)
    schema('double'),
    schema('dynamic'),
    schema('date'),
    schema('date_range'),
    schema('date_value'),
    schema('rate_curve'),

    schema('allocation_type'),
    schema('investment_style'),
    schema('capitalization_type'),

    schema('time_series'),
    //schema('trade_journal'),

    schema('point')
    ..properties = [
      prop('x')..init = 0.0,
      prop('y')..init = 0.0,
    ],
    schema('cost_basis')
    ..properties = [
      prop('units')..type = 'double',
      prop('unit_value')..type = 'double',
    ],
    schema('quantity_bin')
    ..properties = [
      prop('interpolation_type'),
      prop('data')..type = '[point]'
    ],
    schema('rate_curve')
    ..properties = [
      prop('curve_data')..type = '[date_value]'
    ],
    schema('time_series')
    ..properties = [
      prop('data')..type = '[date_value]'
    ],
    schema('capitalization_partition')
    ..properties = [
      prop('small_cap')..type = 'double',
      prop('mid_cap')..type = 'double',
      prop('large_cap')..type = 'double',
    ],
    schema('investment_style_partition')
    ..properties = [
      prop('value')..type = 'double',
      prop('blend')..type = 'double',
      prop('growth')..type = 'double',
    ],
    schema('allocation_partition')
    ..properties = [
      prop('stock')..type = 'double',
      prop('bond')..type = 'double',
      prop('cash')..type = 'double',
      prop('other')..type = 'double',
    ],
    schema('instrument_partitions')
    ..properties = [
      prop('allocation_partition'),
      prop('investment_style_partition'),
      prop('capitalization_partition'),
    ],
    schema('partition_mapping')
    ..doc = '''
Specifies a value that has been partitioned by the partition map
(i.e. percentages summing to 1.0), as well the value unpartitioned.  The
motivation is to allow aggregation of potentially unpartitioned values as well
as the paritioned values according to the percentages provided.
'''
    ..properties = [
      prop('partitioned')..type = 'double',
      prop('unpartitioned')..type = 'double',
      prop('partition_map')..type = '{double}'
    ],
    schema('c_flow_sequence_spec')
    ..properties = [
      prop('date_range'),
      prop('payment_frequency'),
      prop('initial_value')..type = 'date_value',
      prop('growth')..type = 'rate_curve',
    ],
    schema('holding_key')
    ..properties = [
      prop('account_name'),
      prop('holding_name')..doc = 'Name of the holding, a real symbol name or possibly a made up representative name',
    ],
    // schema('asset_key')
    // ..doc = 'An asset on the balance sheet'
    // ..properties = [
    //   prop('asset_name'),
    // ],
    // // schema('funding_key')
    // // ..doc = 'Holdings and assets (potentially) are sources of funding'
    // // ..properties = [
    // //   prop('key')..type = 'dynamic',
    // // ],
    // schema('liability_key')
    // ..doc = 'A liability on the balance sheet'
    // ..properties = [
    //   prop('liability_name'),
    // ],
  ];

  return pkg..finalize();
}

main() => common
  .schema
  .then((schema) => print(jp(schema.schemaMap)));