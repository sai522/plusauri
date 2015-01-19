library plus.json_schema.codegen.flow_model;

import 'package:simple_schema/simple_schema.dart';
import 'package:json_schema/json_schema.dart';
import 'dart:convert' as convert;
import 'package:unittest/unittest.dart';
import 'package:json_schema/schema_dot.dart';
import 'common.dart';
import 'income_statement.dart';

Package get flowModel {

  var pkg = package('flow_model')
  ..defaultRequired = true
  ..imports = [
    common,
    incomeStatement,
  ]
  ..enums = [
  ]
  ..types = [
    schema('flow_spec')
    ..properties = [
      prop('descr'),
      prop('source'),
      prop('c_flow_sequence_spec')
    ],
    schema('flow_key')
    ..properties = [
      prop('name'),
      prop('is_income')..type = 'boolean',
    ],
    schema('flow_type_key')
    ..doc = 'Key that is either ExpenseType or IncomeType'
    ..properties = [
      prop('flow_type'),
    ],
    schema('income_spec')
    ..properties = [
      prop('income_type'),
      prop('flow_spec'),
    ],
    schema('expense_spec')
    ..properties = [
      prop('expense_type'),
      prop('flow_spec'),
    ],
    schema('flow_model')
    ..properties = [
      prop('income_model')..type = '{income_spec}',
      prop('expense_model')..type = '{expense_spec}',
    ],
    schema('income_flows')
    ..properties = [
      prop('income_type'),
      prop('time_series')
    ],
    schema('expense_flows')
    ..properties = [
      prop('expense_type'),
      prop('time_series')
    ],
    schema('realized_flows')
    ..properties = [
      prop('income_flows')..type = '{income_flows}',
      prop('expense_flows')..type = '{expense_flows}'
    ],

  ];

  return pkg..finalize();
}

main() => flowModel
  .schema
  .then((schema) => print(jp(schema.schemaMap)));