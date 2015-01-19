library plus.bin.dart_libs.portfolio;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testPortfolio => testLibrary('test_portfolio')
  ..imports = [
    'package:plus/portfolio.dart',
  ];

Library get portfolio => library('portfolio')
  ..ctorSansNew = true
  ..includeMain = true
  ..includeLogger = true
  ..imports = [
    'math',
    'collection',
    'package:plus/binary_search.dart',
    'package:plus/date.dart',
    'package:plus/date_value.dart',
    'package:plus/date_range.dart',
    'package:plus/time_series.dart',
    'package:basic_input/formatting.dart',
    'package:plus/map_utilities.dart',
    'dart:async',
  ]
  ..enums = [
    enum_('trade_type')
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('buy'), id('sell'),
    ],
    enum_('capitalization')
    ..doc = 'Breakdown of capitalization'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('large_cap'), id('mid_cap'), id('small_cap'),
    ],
    enum_('investment_style')
    ..doc = 'Style of fund investment'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('value'), id('blend'), id('growth'),
    ],
    enum_('lot_close_method')
    ..doc = 'Determines how sales close out lots'
    ..jsonSupport = true
    ..libraryScopedValues = true
    ..values = [
      id('fifo'), id('lifo'), id('hifo'), id('low_cost'), id('average_cost')
    ],
  ]
  ..parts = [
    part('account')
    ..defaultMemberAccess = IA
    ..classes = [
      // class_('account')
      // ..members = [
      //   member('id')..ctors = [''],
      //   member('portfolio')..type = 'Portfolio'..ctors = [''],
      // ]
    ],
    part('portfolio')
    ..defaultMemberAccess = RO
    ..classes = [
      class_('portfolio')
      ..doc = 'A map of holdings with a particular asOf date'
      ..jsonSupport = true
      ..members = [
        member('as_of')..type = 'Date'..ctors=[''],
        member('holdings')..type = 'Map<String,double>'..ctors = ['']..classInit = {},
      ],
      class_('portfolio_history')
      ..jsonSupport = true
      ..ctorCustoms = ['']
      ..members = [
        member('portfolio_source')
        ..type = 'Portfolio',
        member('trade_journal')
        ..type = 'TradeJournal'..classInit = 'new TradeJournal.empty()',
        member('date_range')..type = 'DateRange',
        member('holding_histories')
        ..type = 'Map<String,TimeSeries>'..classInit = {},
      ],
    ],
    part('trade_journal')
    ..ctorSansNew = false
    ..classes = [
      class_('trade')
      ..ctorSansNew = false
      ..builder = true
      ..copyable = true
      ..allMembersFinal = true
      ..courtesyCtor = true
      ..jsonSupport = true
      ..opEquals = true
      ..comparable = true
      ..members = [
        member('date')..type = 'Date',
        member('symbol'),
        member('trade_type')..type = 'TradeType',
        member('quantity')..type = 'double',
        member('price')..type = 'double',
      ],
      class_('trade_journal')
      ..copyable = true
      ..jsonSupport = true
      ..opEquals = true
      ..defaultMemberAccess = RO
      ..ctorSansNew = false
      ..members = [
        member('trades')
        ..type = 'List<Trade>',
        member('date_range')
        ..type = 'DateRange',
      ],
      class_('trade_account_collection')
      ..doc = 'Encapsulates "accounts" of trade journals in a map indexed by account name'
      ..jsonSupport = true
      ..members = [
        member('trade_journal_map')
        ..type = 'Map<String,TradeJournal>'
        ..classInit = {}
        ..ctors = [''],
      ],
      class_('cost_basis_entry')
      ..builder = true
      ..copyable = true
      ..allMembersFinal = true
      ..courtesyCtor = true
      ..members = [
        member('sell')..type = 'Trade',
        member('offsetting_buys')..type = 'List<Trade>',
        member('cost')..type = 'double',
        member('short_term_gain')..type = 'double',
        member('long_term_gain')..type = 'double',
        member('lot_close_method')..type = 'LotCloseMethod',
      ],
      class_('lot_closer')
      ..isAbstract = true,
      class_('f_i_f_o_lot_closer')
      ..extend = 'LotCloser',
      class_('l_i_f_o_lot_closer')
      ..extend = 'LotCloser',
      class_('h_i_f_o_lot_closer')
      ..extend = 'LotCloser',
      class_('low_cost_lot_closer')
      ..extend = 'LotCloser',
      class_('trade_tax_assessor')
      ..doc = 'Calculates taxes on trade journals'
      ..defaultMemberAccess = RO
      ..members = [
        member('trade_journal')..type = 'TradeJournal'..ctors = [''],
        member('closed_lots')..type = 'List<Trade>'..classInit = [],
        member('open_lots')..type = 'List<Trade>'..classInit = [],
        member('cost_basis_entries')..type = 'List<CostBasisEntry>'..classInit = [],
        member('short_term_gain')..classInit = 0.0,
        member('long_term_gain')..classInit = 0.0,
      ],
      class_('match_result')
      ..allMembersFinal = true
      ..courtesyCtor = true
      ..ctorSansNew = false
      ..members = [
        member('sell')..type = 'Trade',
        member('matched_buys')..type = 'List<Trade>',
        member('residual_trade')..type = 'Trade',
        member('remaining_buys')..type = 'List<Trade>',
        member('lot_close_method')..type = 'LotCloseMethod',
      ],
      class_('avg_cost_accumulator')
      ..copyable = true
      ..members = [
        member('total_cost')..type = 'double',
        member('total_value')..type = 'double',
        member('total_qty')..type = 'double',
      ]
    ]
  ]
  ..classes = [
    class_('price_resolver')
    ..isAbstract = true
    ..ctorSansNew = false
    ..members = [
    ],
    class_('p_r_results')
    ..jsonSupport = true
    ..members = [
      member('prices')
      ..type = 'Map<String,TimeSeries>'
      ..ctors = [''],
    ],
    class_('p_r_request')
    ..members = [
      member('date_range')..type = 'DateRange'..isFinal = true..ctors = [''],
      member('symbols')..type = 'Set<String>'..isFinal = true..ctors = [''],
    ],
  ];

get libs => [ portfolio ];
get testLibs => [ testPortfolio ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
