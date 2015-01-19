library plus.json_schema.codegen.assumption;

import 'package:simple_schema/simple_schema.dart';
import 'common.dart';
import 'flow_model.dart';

Package get assumption {

  var pkg = package('assumption')
  ..defaultRequired = true
  ..imports = [
    common,
    flowModel,
  ]
  ..enums = [
    ssEnum('holding_return_type',
        [
          'interest',
          'qualified_dividend',
          'unqualified_dividend',
          'capital_gain_distribution',
          'capital_appreciation',
        ]),
    ssEnum('liquidation_sort_type',
        [
          'sell_farthest_partition',
          'sell_largest_gainer',
        ]),
    ssEnum('investment_sort_type',
        [
          'buy_closest_partition',
          'buy_largest_loser',
        ]),
  ]
  ..types = [
    schema('holding_returns')
    ..doc = '''
Provides (potentially) a blend of returns based on [HoldingReturnType].'''
    ..properties = [
      prop('returns')..type = 'rate_curve[holding_return_type]',
    ],
    schema('instrument_assumptions')
    ..doc = '''
Describes the type of holding (Stock, Bond, ... Blend) and various paritions.
'''
    ..properties = [
      prop('holding_type'),
      prop('holding_returns'),
      prop('instrument_partitions'),
    ],
    schema('reserve_assumptions')
    ..properties = [
      prop('excess')..type = 'rate_curve',
      prop('shortfall')..type = 'rate_curve',
    ],
    schema('reinvestment_policy')
    ..properties = [
      prop('dividends_reinvested')..type = 'boolean',
      prop('interest_reinvested')..type = 'boolean',
    ],
    schema('date_assumptions')
    ..properties = [
      prop('death_date')..type = 'date',
      prop('retirement_date')..type = 'date',
    ],
    schema('account_assumptions')
    ..properties = [
      prop('other_instrument_assumptions')..type = 'instrument_assumptions',
      prop('default_reinvestment_policy')..type = 'reinvestment_policy',
      prop('holding_reinvestment_policies')..type = '{reinvestment_policy}'
    ],
    schema('balance_sheet_assumptions')
    ..properties = [
      prop('asset_assumptions')..type = '{rate_curve}',
      prop('liability_assumptions')..type = '{rate_curve}',

      prop('account_assumptions')..type = '{account_assumptions}',
      prop('instrument_assumptions')..type = '{instrument_assumptions}',
    ],
    schema('strategy_assumptions')
    ..properties = [
      prop('target_partitions')..type = 'instrument_partitions',
      prop('emergency_reserves')..init = 0.0
      ..doc = 'Desired amount to keep in reserves before investing any excesses',
      prop('liquidation_sort_type'),
      prop('investment_sort_type'),
    ],
    schema('tax_rate_assumptions')
    ..properties = [
      prop('pension_income')..type = 'rate_curve',
      prop('social_security_income')..type = 'rate_curve',
      prop('capital_gains')..type = 'rate_curve',
      prop('dividends')..type = 'rate_curve',
      prop('rental_income')..type = 'rate_curve',
      prop('ordinary_income')..type = 'rate_curve',
    ],
    schema('assumption_model')
    ..properties = [
      prop('inflation')..type = 'rate_curve',
      prop('balance_sheet_assumptions'),
      prop('income_model_overrides')..type = '{income_spec}',
      prop('expense_model_overrides')..type = '{expense_spec}',
      prop('date_assumptions')..type = '{date_assumptions}',
      prop('strategy_assumptions'),
      prop('tax_rate_assumptions'),
      prop('reserve_assumptions'),
    ]
  ];

  return pkg..finalize();
}

main() => assumption
  .schema
  .then((schema) => print(jp(schema.schemaMap)));