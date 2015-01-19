library plus.json_schema.codegen.dossier;

import 'package:simple_schema/simple_schema.dart';
import 'balance_sheet.dart';
import 'flow_model.dart';
import 'assumption.dart';
import 'common.dart';


Package get dossier {

  var pkg = package('dossier')
  ..imports = [
    common,
    balanceSheet,
    flowModel,
    assumption,
  ]
  ..defaultRequired = true
  ..types = [
    schema('person')
    ..properties = [
      prop('birth_date')..type = 'date',
      prop('death_date')..type = 'date',
      prop('retirement_date')..type = 'date',
    ],
    schema('dossier')
    ..properties = [
      prop('id'),
      prop('person_map')..type = '{person}',
      prop('balance_sheet'),
      prop('flow_model'),
      prop('assumption_model'),
      prop('alternate_assumption_models')..type = '{assumption_model}',
      prop('funding_links')
      ..doc ='''Links a flow model expense to an account for funding

Note: A funding source can only be used its specified expense. However,
expenses can be funded by other sources. The intent is to model constraints like
college expenses being funded first by college funds.
'''
      ..type = '{string}',
      prop('investment_links')
      ..doc ='Links a flow model income to one or more accounts.'
      ..type = '{string}',
    ],
  ];

  return pkg..finalize();
}

main() => dossier
  .schema
  .then((schema) => print(jp(schema.schemaMap)));
