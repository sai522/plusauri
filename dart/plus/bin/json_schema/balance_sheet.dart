library plus.json_schema.codegen.balance_sheet;

import 'package:simple_schema/simple_schema.dart';
import 'common.dart';

Package get balanceSheet {

  var pkg = package('balance_sheet')
  ..defaultRequired = true
  ..imports = [
    common
  ]
  ..enums = [
  ]
  ..types = [
    schema('holding')
    ..doc = '''

The holding for a given symbol (or a sythetic aggregate as in an account other_holdings).

Both quantity and unitValue have dates associated with them. The marketValue of
the holding is based on the latest date of the two. This date can be different
(most likely older) than the date associated with the BalanceSheet owning the
holding.'''
    ..properties = [
      prop('holding_type'),
      prop('quantity')..type = 'date_value',
      prop('unit_value')..type = 'date_value',
      prop('cost_basis')..type = 'double',
    ],
    schema('portfolio_account')
    ..doc = '''
The map of holdings indexed by symbol (or similar name unique to the portfolio).
'''
    ..properties = [
      prop('account_type'),
      prop('descr'),
      prop('owner'),
      prop('holding_map')..type = '{holding}',
      prop('other_holdings')
      ..doc = '''
Market value of all account holdings not specified in the holding map.

This gives the ability to enter an account with a market value and specific tax
treatment without having to fully specify all holdings individually.
'''
      ..type = 'holding',
    ],
    schema('b_s_item')
    ..doc = '''
A balance sheet item (i.d. data common to Assets and Liabilities)'''
    ..properties = [
      prop('acquired')..type = 'date_value',
      prop('retired')..type = 'date_value',
      prop('descr'),
      prop('owner'),
      prop('current_value')..type = 'date_value',
    ],
    schema('asset')
    ..properties = [
      prop('asset_type'),
      prop('b_s_item'),
    ],
    schema('liability')
    ..properties = [
      prop('liability_type'),
      prop('b_s_item'),
    ],
    schema('balance_sheet')
    ..properties = [
      prop('as_of')..type = 'date',
      prop('asset_map')..type = '{asset}',
      prop('liability_map')..type = '{liability}',
      prop('portfolio_account_map')..type = '{portfolio_account}',
    ],
  ];

  return pkg..finalize();
}

main() => balanceSheet
  .schema
  .then((schema) => print(jp(schema.schemaMap)));