library plus.bin.dart_libs.finance;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

var _commonImports = [
  'math',
  'package:plus/finance.dart',
  'package:plus/date.dart',
  'package:plus/date_value.dart',
  'package:plus/test_utils.dart',
];

List<Library> get testLibs =>[
  testLibrary('test_finance_mortgage')
  ..imports.addAll(_commonImports),
  testLibrary('test_finance_rate_curve')
  ..imports.addAll(_commonImports),
  testLibrary('test_finance_cash_flow')
  ..imports.addAll(_commonImports),
  testLibrary('test_finance_tvm')
  ..imports.addAll(_commonImports),
  testLibrary('test_finance_curves_attribution')
  ..imports.addAll(_commonImports),
];

Library get lib => library('finance')
  ..imports.addAll([
    '"dart:convert" as convert',
    'math',
    'package:plus/date.dart',
    'package:plus/date_value.dart',
    'package:plus/date_range.dart',
    'package:plus/map_utilities.dart',
  ])
  ..enums = [
    enum_('capitalization_type')
    ..doc = 'Breakdown of small, mid and large cap'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('small_cap'), id('mid_cap'), id('large_cap'),
    ],
    enum_('investment_style')
    ..doc = 'Breakdown by style'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('value_investment'), id('blend_investment'), id('growth_investment'),
    ],
    enum_('allocation_type')
    ..doc = 'Breakdown by stock/bond/cash/other'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('stock_allocation'), id('bond_allocation'), id('cash_allocation'), id('other')
    ],
  ]
  ..parts = [
    part('cash_flow')
    ..classes = [
      class_('c_flow_sequence')
      ..ctorSansNew = true
      ..members = [
        member('flows')
        ..isFinal = true
        ..access = RO
        ..type = 'List<DateValue>'
        ..ctors = ['assume_sorted']
      ]
    ],
    part('rate_curve')
    ..classes = [
      class_('rate_curve')
      ..jsonSupport = false
      ..opEquals = true
      ..members = [
        member('curve_data')
        ..isFinal = true
        ..access = RO
        ..type = 'List<DateValue>'
        ..ctors = ['assume_sorted']
      ]
    ],
    part('curves_attribution')
    ..classes = [
      class_('curves_attribution')
      ..opEquals = true
      ..defaultMemberAccess = IA
      ..ctorSansNew = true
      ..members = [
        member('curves_attribution')
        ..isFinal = true
        ..access = RO
        ..type = 'Map<Object, RateCurve>'
        ..ctors = ['']
      ],
      class_('attribution')
      ..opEquals = true
      ..defaultMemberAccess = IA
      ..ctorSansNew = true
      ..members = [
        member('attribution')
        ..isFinal = true
        ..access = RO
        ..type = 'Map<Object, double>'
        ..ctors = ['']
      ]
    ],
    part('tvm'),
    part('mortgage')
    ..classes = [
      class_('mortgage_spec')
      ..members = [
        member('principal')..type = 'num'..ctors = [''],
        member('rate')..type = 'num'..ctors = [''],
        member('term')..type = 'num'..ctors = [''],
      ],
      class_('mortgage_paydown_record')
      ..members = [
        member('date')..type = 'DateTime',
        member('period_interest_paid')..type = 'num',
        member('period_principal_paid')..type = 'num',
        member('remaining_principal')..type = 'num',
      ]
    ],
  ];

get libs => [ lib ];

void main() {
  plus
    ..libraries = libs
    ..testLibraries = testLibs
    ..generate( generateHop : false );
}