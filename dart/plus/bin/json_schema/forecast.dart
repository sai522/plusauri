library plus.json_schema.codegen.forecast;

import 'package:simple_schema/simple_schema.dart';
import 'common.dart';
import 'balance_sheet.dart';
import 'income_statement.dart';
import 'liquidation_summary.dart';

Package get forecast {

  var pkg = package('forecast')
  ..defaultRequired = true
  ..imports = [
    common,
    balanceSheet,
    //    incomeStatement,
    //    liquidationSummary,
  ]
  ..types = [
    schema('distribution_breakdown')
      ..doc = '''
Tracks dividends by type - irrespective of reinvestment policy
'''
    ..properties = [
      prop('qualified')..init = 0.0,
      prop('unqualified')..init = 0.0,
      prop('capital_gain_distribution')..init = 0.0,
      prop('interest')..init = 0.0,
    ],
    schema('distribution_summary')
    ..doc = '''
Track distributions by those that are reinvested vs those that are distributed.
'''
    ..properties = [
      prop('distributed')..type = 'DistributionBreakdown',
      prop('reinvested')..type = 'DistributionBreakdown',
    ],
    schema('period_balance')
    ..doc = 'Balance at endpoints of a given period'
    ..properties = [
      prop('start')..type = 'DateValue',
      prop('end')..type = 'DateValue',
    ],
    schema('instrument_partition_mappings')
    ..doc = '''Collection of the most prominant partitions.
Can be applied to instrument valuations as well as accounts, synthetics, etc.
'''
    ..properties = [
      prop('allocation')..type = 'partition_mapping',
      prop('style')..type = 'partition_mapping',
      prop('capitalization')..type = 'partition_mapping',
    ],
    schema('holding_period_balance')
    ..doc = 'Balance at endpoints of a given period plus additional dividend and balance change breakdown details'
    ..properties = [
      prop('holding_type'),
      prop('period_balance')..type = 'PeriodBalance',
      prop('distribution_summary'),
      prop('cost_basis')..type = 'PeriodBalance',
      prop('capital_gain')..type = 'double',
      prop('end_value_partitions')..type = 'instrument_partition_mappings',
      prop('growth_details')
      ..doc = 'Details on modeled growth from start to end - (does *not* including sales/investments)'
      ..type = 'number[holding_return_type]',
      prop('sold_invested')
      ..doc = 'Value sold/invested into over the period'
      ..type = 'double'
    ],
    schema('tax_assessment')
    ..properties = [
      prop('taxing_authority'),
      prop('tax_bases')..type = 'number[tax_category]',
      prop('tax_bill')..init = 0.0,
    ],
  ];

  return pkg..finalize();
}

main() => forecast
  .schema
  .then((schema) => print(jp(schema.schemaMap)));