library plus.json_schema.codegen.liquidation_summary;

import 'package:simple_schema/simple_schema.dart';
import 'common.dart';

Package get liquidationSummary {

  var pkg = package('liquidation_summary')
  ..defaultRequired = true
  ..imports = [
    common,
  ]
  ..types = [
    schema('flow_detail')
    ..doc = 'Allows income/expense flows to be comingled by time'
    ..properties = [
      prop('date'),
      prop('type')..type = 'integer',
      prop('flow')..type = 'double',
      prop('name'),
    ],
    schema('funding_adjustment')
    ..doc = 'Documents an adjustment to a holding/asset to fund/invest'
    ..properties = [
      prop('flow_detail'),
      prop('holding_key'),
      prop('amount')..doc = 'Amount added/subtracted to the account'..type = 'double',
      prop('end_balance')..type = 'double',
      prop('flow_remaining')..type = 'double'
    ],
    schema('flow_entry')
    ..properties = [
      prop('flow_detail'),
      prop('funding_adjustments')..type = '[funding_adjustment]'
    ],
    schema('liquidation_summary')
    ..properties = [
      prop('flow_entries')..type = '[flow_entry]',
    ],
  ];

  return pkg..finalize();
}

main() => liquidationSummary
  .schema
  .then((schema) => print(jp(schema.schemaMap)));