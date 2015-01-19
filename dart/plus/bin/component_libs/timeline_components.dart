library plus.codegen.dart.component_libs.timeline_components;

import "dart:io";
import "dart:math";
import "package:id/id.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:ebisu_web_ui/ebisu_web_ui.dart";
import "package:path/path.dart";
import "../root_path.dart";

String _here = join(dirname(rootPath), 'component_libs');

ComponentLibrary get timeline_components =>
  componentLibrary('timeline_forecast')
  ..prefix = 'plus'
  ..rootPath = _here
  ..examples = [
    example(idFromString('timeline'))
    ..initPolymer = false,
    example(idFromString('timeline_nav'))
    ..initPolymer = false,
    example(idFromString('income_statement'))
    ..initPolymer = false,
    example(idFromString('annual_forecast'))
    ..initPolymer = false,
    example(idFromString('holding_period_balance'))
    ..initPolymer = false,
  ]
  ..pubSpec.addDependency(pubdep('tooltip'))
  ..libraries = [
    library('timeline_enums')
    ..enums = [
      enum_('display_type')
      ..libraryScopedValues = true
      ..doc = 'Types of display in the timeline'
      ..values = [
        id('net_worth'),
        id('reserves'),
        id('total_assets'),
        id('total_liabilities'),
        id('net_income'),
        id('total_income'),
        id('total_expense'),
        id('inflation'),
      ],
      enum_('balance_display_type')
      ..libraryScopedValues = true
      ..doc = 'Types of balance displays in the timeline'
      ..values = [
        id('net_worth_balance'),
        id('total_assets_balance'),
        id('total_liabilities_balance'),
      ],
      enum_('flow_display_type')
      ..libraryScopedValues = true
      ..doc = 'Types of income/expense displays in the timeline'
      ..values = [
        id('net_income_flow'),
        id('total_income_flow'),
        id('total_expense_flow'),
      ],
      enum_('nav_content_type')
      ..libraryScopedValues = true
      ..doc = 'List of content types, one of which may be displayed in the nav at a time'
      ..values = [
        id('net_worth_content'),
        id('total_assets_content'),
        id('total_liabilities_content'),
        id('net_income_content'),
        id('total_income_content'),
        id('total_expense_content'),
      ],
      enum_('annual_component_type')
      ..libraryScopedValues = true
      ..doc = 'Types of components displayed in annual forecast'
      ..values = [
        id('balance_sheet_component'),
        id('income_statement_component'),
        id('tax_summary_component'),
        id('liquidation_summary_component'),
      ]
    ],
    library('timeline_header_model')
    ..imports = [
      'package:timeline_forecast/timeline_enums.dart',
    ]
    ..classes = [
      class_('timeline_header_model')
      ..defaultMemberAccess = IA
      ..members = [
      ],
    ],
    library('current_dollars')
    ..imports = [
      'package:plus/date.dart',
      'package:plus/date_value.dart',
      'package:plus/finance.dart',
    ]
    ..classes = [
      class_('current_dollars_toggler')
      ..members = [
        member('today')..type = 'Date'..ctors = ['']..access = RO,
        member('inflation')..type = 'RateCurve'..ctors = ['']..access = RO,
        member('showing_current_dollars')..classInit = false..access = RO,
      ]
    ],
    library('composite_table')
    ..imports = [
      'html',
      '"package:quiver/iterables.dart" as quiver',
    ]
    ..classes = [
      class_('composite_table')
      ..defaultMemberAccess = IA
      ..members = [
        member('top_rows')..type = 'List<CompositeRow>'..classInit = [],
        member('rows')..type = 'Map<String, CompositeRow>'..classInit = {},
        member('table')..type = 'TableElement'..ctors = [''],
      ],
      class_('composite_row')
      ..defaultMemberAccess = IA
      ..members = [
        member('children')..type = 'List<CompositeRow>'..classInit = [],
        member('is_hidden')
        ..doc = 'Indicates user has requested row be hidden'
        ..classInit = false,
        member('is_collapsed')
        ..doc = '''
Indicates this row is collapsed (i.e. no children displayed).
The row itself may also be hidden by user
'''
        ..classInit = false..access = RO,
        member('is_collapse_hidden')
        ..doc = '''
Indicates the row should not be displayed because it is hidden due to its parent
being collapsed.
'''
        ..classInit = false,
        member('row')..type = 'TableRowElement'..access = RO..ctors = [ '' ],
        member('indent_level')..classInit = 0..access = RO,
        member('collapse_visual')..type = 'CollapseVisual'..access = RW,
      ]
    ],
    library('year_axis')
    ..imports = [
      'html',
      "'dart:svg' hide Point",
      "'dart:svg' as svg show Point",
      "'dart:math' show min, max, Point",
      'async',
      //'package:plus/models/common.dart',
    ]
    ..classes = [
      class_('year_axis')
      ..defaultMemberAccess = IA
      ..ctorCustoms = ['']
      ..members = [
        member('start')..doc = 'Starting offset for the axis within svg'
        ..type = 'Point'..classInit = 'new Point(0.0,0.0)',
        member('start_year')..classInit = 0..ctors = [''],
        member('end_year')..classInit = 0..ctors = [''],
        member('group')..type = 'GElement'..classInit = 'new GElement()',
        member('width')..classInit = 0.0,
        member('inner_dim')..type = 'Point'..classInit = 'new Point(0.0,0.0)',
        member('height')..classInit = 100.0,
        member('num_years')..classInit = 0,
        member('year_width')..classInit = 0.0,
        member('year_positions')..type = 'List<num>'..classInit = [],
        member('year_top_labels')..type = 'List<TextElement>'..classInit = [],
        member('year_bottom_labels')..type = 'List<TextElement>'..classInit = [],
        member('top_line')..type = 'LineElement'..classInit = 'new LineElement()',
        member('bottom_line')..type = 'LineElement'..classInit = 'new LineElement()',
        member('year_lines')..type = 'List<LineElement>'..classInit = [],
        member('year_to_line_pad')..classInit = 2.0,
        member('font_size')..classInit = '9',
        member('top_margin')..classInit = 9.0,
        member('bottom_margin')..classInit = 9.0,
        member('left_margin')..classInit = 7.0,
        member('right_margin')..classInit = 7.0,
        member('top_line_y')..classInit = 0.0,
        member('bottom_line_y')..classInit = 0.0,
        member('top_label_y')..classInit = 0.0,
        member('bottom_label_y')..classInit = 0.0,
        member('highlight_rect')..type = 'RectElement'
        ..classInit = 'new RectElement()',
        member('calculated_index')..classInit = -1,
        member('left_label_elements')..type = 'Map<double, TextElement>'..classInit = {},
      ]
    ],
    library('test_timeline_model')
    ..imports = [
      'package:timeline_forecast/timeline_model.dart',
      'package:plus/repository.dart',
    ]
    ..isTest = true,
    library('timeline_model')
    ..includeLogger = true
    ..imports = [
      // 'package:ebisu/ebisu_utils.dart',
      // 'package:plus/models/common.dart',
      'collection',
      "'dart:math' show min, max",
      'package:plus/date.dart',
      'package:plus/date_value.dart',
      'package:plus/time_series.dart',
      'package:plus/date_range.dart',
      'package:plus/finance.dart',
      'package:plus/forecast.dart',
      'package:plus/models/common.dart',
      'package:plus/models/dossier.dart',
      'package:plus/models/forecast.dart',
      'package:plus/models/assumption.dart',
      'package:plus/models/income_statement.dart',
      'package:plus/models/liquidation_summary.dart',
      'package:timeline_forecast/timeline_enums.dart',
      'package:timeline_forecast/current_dollars.dart',
      // 'package:plus/models/flow_model.dart',
      // 'package:plus/models/assumption.dart',
    ]
    ..parts = [
      part('grid_timeline')
      ..classes = [
        class_('grid_timeline_model')
        ..defaultMemberAccess = RO
        ..implement = [ 'ITimelineModel' ]
        ..ctorCallsInit = true
        ..members = [
          member('forecast_grid')..type = 'ForecastGrid'..ctors = ['']..isFinal = true,
          member('inflation')..type = 'RateCurve'..ctors = ['']..isFinal = true,
          member('net_worth')..type = 'ForecastBalances'..access = RO,
          member('reserves')..type = 'ForecastBalances'..access = RO,
          member('net_assets')..type = 'ForecastBalances'..access = RO,
          member('net_liabilities')..type = 'ForecastBalances'..access = RO,

          member('net_incomes')..type = 'ForecastFlows'..access = RO,
          member('net_expenses')..type = 'ForecastFlows'..access = RO,
          member('net_flows')..type = 'ForecastFlows'..access = RO,

          member('annual_forecasts_lazy')..type = 'List<IAnnualForecastModel>',
        ],
        class_('grid_balance_sheet_model')
        ..implement = [ 'IBalanceSheetModel' ]
        ..defaultMemberAccess = RO
        ..ctorCallsInit = true
        ..members = [
          member('forecast_grid')..type = 'ForecastGrid'..ctors = ['']..isFinal = true,
          member('grid_year')..type = 'GridYear'..ctors = ['']..isFinal = true,
        ],
        class_('grid_income_statement_model')
        ..implement = [ 'IIncomeStatementModel' ]
        ..defaultMemberAccess = RO
        ..members = [
          member('forecast_grid')..type = 'ForecastGrid'..ctors = ['']..isFinal = true,
          member('year')..type = 'int'..ctors = ['']..isFinal = true,
        ],
        class_('grid_liquidation_summary_model')
        ..implement = [ 'ILiquidationSummaryModel' ]
        ..defaultMemberAccess = RO
        ..ctorCallsInit = true
        ..members = [
          member('forecast_grid')..type = 'ForecastGrid'..ctors = ['']..isFinal = true,
          member('grid_year')..type = 'GridYear'..ctors = ['']..isFinal = true,
          member('original_balances')..type = 'Map<HoldingKey, double>'..classInit = {}..access = IA,
          member('original_net_trade')..classInit = 0.0..access = IA,
        ],
        class_('grid_tax_summary_model')
        ..implement = [ 'ITaxSummaryModel' ]
        ..defaultMemberAccess = RO
        //..ctorCallsInit = true
        ..members = [
          member('previous_grid_year')..type = 'GridYear'..isFinal = true,
          member('grid_year')..type = 'GridYear'..isFinal = true,
          member('sheltered_distributions')..type = 'DistributionBreakdown',
        ],
        class_('grid_annual_forecast_model')
        ..implement = [ 'IAnnualForecastModel' ]
        ..defaultMemberAccess = RO
        ..ctorCallsInit = true
        ..members = [
          member('forecast_grid')..type = 'ForecastGrid'..ctors = ['']..isFinal = true,
          member('title')..ctors = ['']..isFinal = true,
          member('year')..type = 'int'..ctors = ['']..isFinal = true,
          member('balance_sheet_model')..type = 'IBalanceSheetModel'..access = RO,
          member('income_statement_model')..type = 'IIncomeStatementModel'..access = RO,
          member('liquidation_summary_model')..type = 'ILiquidationSummaryModel'..access = RO,
          member('tax_summary_model')..type = 'ITaxSummaryModel'..access = RO,
        ],
      ],
    ]
    ..classes = [
      class_('i_timeline_model')..isAbstract = true,
      class_('timeline_comparison_model')
      ..doc = 'Supports multiple models over specific multiyear period'
      ..members = [
        member('date_range')
        ..doc = 'Range of the forecasts - it is assumed all forecasts are on the same range'
        ..type = 'DateRange'..access = RO,
        member('timeline_models')..type = 'Map<String, ITimelineModel>'..classInit = {}
      ],
      class_('i_balance_sheet_model')..isAbstract = true,
      class_('i_income_statement_model')..isAbstract = true,
      class_('i_tax_summary_model')..isAbstract = true,
      class_('i_liquidation_summary_model')..isAbstract = true,
      class_('i_annual_forecast_model')..isAbstract = true,
      class_('forecast_balances')
      ..defaultMemberAccess = IA
      ..ctorSansNew = true
      ..ctorCustoms = ['']
      ..members = [
        member('title')
        ..ctors = ['']
        ..access = RO,
        member('period_balances')
        ..type = 'List<PeriodBalance>'
        ..ctors = ['']
        ..classInit = []
        ..access = RO,
        member('min_balance')
        ..access = RO
        ..type = 'double'
        ..classInit = 'double.MAX_FINITE',
        member('max_balance')
        ..access = RO
        ..classInit = 0.0,
      ],
      class_('year_income_flows')
      ..ctorSansNew = true
      ..members = [
        member('year')..classInit = 0,
        member('net_flow')..classInit = 0.0,
      ],
      class_('forecast_flows')
      ..ctorSansNew = true
      ..defaultMemberAccess = IA
      ..members = [
        member('title')
        ..ctors = ['']
        ..access = RO,
        member('flows_by_year')
        ..type = 'List<YearIncomeFlows>'
        ..ctors = ['']
        ..classInit = []
        ..access = RO,
        member('min_flow')..access = RO..type = 'double'..classInit = 'double.MAX_FINITE',
        member('max_flow')..access = RO..classInit = 0.0,
      ],
    ]
  ]
  ..components = [
    component('t_f_nav_content_selector')
    ..imports = [
      'package:timeline_forecast/timeline_enums.dart',
      "'package:quiver/iterables.dart' hide min, max",
    ]
    ..implClass = (class_('t_f_nav_content_selector')
        ..defaultMemberAccess = IA
        ..members = [
          member('nav_content_type')..isObservable = true..access = RW
          ..type = 'NavContentType',
          member('net_worth_button')..type = 'Element',
          member('total_assets_button')..type = 'Element',
          member('total_liabilities_button')..type = 'Element',
          member('net_income_button')..type = 'Element',
          member('total_income_button')..type = 'Element',
          member('total_expense_button')..type = 'Element',
        ]),
    component('t_f_annual_component_toggler')
    ..imports = [
      'package:timeline_forecast/timeline_enums.dart',
    ]
    ..implClass = (class_('t_f_annual_component_toggler')
        ..defaultMemberAccess = IA
        ..members = [
          member('balance_sheet_button')..type = 'Element',
          member('income_statement_button')..type = 'Element',
          member('tax_summary_button')..type = 'Element',
          member('liquidation_summary_button')..type = 'Element',
          member('toggled_on_set')..type = 'Set'
          ..isObservable = true..access = RW
          ..isFinal = true
          ..classInit = 'new Set.from(AnnualComponentType.values)',
        ]),
    component('t_f_annual_forecast')
    ..imports = [
      'async',
      'package:plus/models/forecast.dart',
      'package:timeline_forecast/timeline_model.dart',
      'package:timeline_forecast/timeline_enums.dart',
      //'package:animation/animation.dart',
      't_f_annual_component_toggler.dart',
      't_f_balance_sheet.dart',
      't_f_income_statement.dart',
      't_f_tax_summary.dart',
      't_f_liquidation_summary.dart',
    ]
    ..implClass = (class_('t_f_annual_forecast')
        ..defaultMemberAccess = IA
        ..members = [
          member('annual_forecast_title')..isObservable = true..access = RW,
          member('year')..classInit=0..isObservable = true..access = RW,

          member('balance_sheet_hider')..type = '_ComponentHider',
          member('income_statement_hider')..type = '_ComponentHider',
          member('tax_summary_hider')..type = '_ComponentHider',
          member('liquidation_summary_hider')..type = '_ComponentHider',

          member('annual_forecast_model')..type = 'IAnnualForecastModel',
        ])
    ..supportClasses = [
      class_('component_hider')
      ..isPublic = false
      ..ctorCustoms = ['']
      ..members = [
        member('element')..type = 'Element'..ctors = [''],
        member('is_shown')..classInit = true,
        member('computed_width')..classInit = 0.0,
        member('computed_padding')..classInit = 0.0,
        //member('element_animation')..type = 'ElementAnimation',
        member('px_regex')..type = 'RegExp'..isStatic = true..isFinal = true
        ..classInit = r"new RegExp(r'([\d.]+)px')"
      ]
    ],
    component('t_f_partitions')
    ..imports = [
      'html',
      "'package:plus/models/common.dart' hide Point",
      "'dart:svg' hide Point",
      "'dart:svg' as svg show Point",
      "'dart:math' show min, max, Point",
      'package:basic_input/formatting.dart',
    ]
    ..implClass = (class_('t_f_partitions')
        ..defaultMemberAccess = IA
        ..members = [
          member('header')..type = 'DivElement',
          member('svg_container')..type = 'SvgSvgElement'..classInit = 'new SvgSvgElement()',
          member('group')..type = 'GElement'..classInit = 'new GElement()',
          member('shell_div')..type = 'DivElement',
          member('point')..type = 'svg.Point',
          member('allocation_details')..type = 'PartitionDetails',
          member('style_details')..type = 'PartitionDetails',
          member('capitalization_details')..type = 'PartitionDetails',
          member('vertical_axis')..type = 'LineElement'..classInit = 'new LineElement()',
          member('horizontal_axis')..type = 'LineElement'..classInit = 'new LineElement()',
        ])
    ..supportClasses = [
      class_('partition_details')
      ..defaultMemberAccess = IA
      ..ctorCustoms = ['']
      ..members = [
        member('id')..ctors = [''],
        member('radio_button')..type = 'InputElement'..ctors = [''],
        member('svg_container')..type = 'SvgSvgElement'..ctors = [''],
        member('title')..type = 'TextElement'..classInit = 'new TextElement()',
        member('partition_mapping')..type = 'PartitionMapping',
        member('label_map')..classInit = {},
        member('group')..type = 'GElement'..classInit = 'new GElement()',
        member('bars')..type = 'List<BarDetails>'..classInit = [],
        member('vertical_dividers')..type = 'List<VerticalDivider>'..classInit = [],
        member('min_pct')..type = 'double'..classInit = 'double.MAX_FINITE',
        member('max_pct')..type = 'double'..classInit = '-double.MAX_FINITE',
      ],
      class_('bar_details')
      ..defaultMemberAccess = IA
      ..members = [
        member('bar')..type = 'RectElement'..classInit = 'new RectElement()',
        member('value')..classInit = 0.0,
        member('percent')..classInit = 0.0,
        member('label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('value_label')..type = 'TextElement'..classInit = 'new TextElement()',
      ],
      class_('vertical_divider')
      ..defaultMemberAccess = IA
      ..ctorCustoms = ['']
      ..members = [
        member('top_label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('bottom_label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('vertical')..type = 'LineElement'..classInit = 'new LineElement()',
      ]
    ],
    component('t_f_holding_period_balance')
    ..imports = [
      'package:plus/finance.dart',
      'package:basic_input/formatting.dart',
      'package:plus/date_value.dart',
      'package:plus/models/forecast.dart',
      'package:tooltip/components/tooltip.dart',
      'package:timeline_forecast/composite_table.dart',
      't_f_partitions.dart',
    ]
    ..enums = [
      enum_('row_type')
      ..libraryScopedValues = true
      ..doc = 'Types of rows in TFHoldingPeriodBalance'
      ..values = [
        id('account_row'),
        id('symbol_row'),
        id('start_date_row'),
        id('end_date_row'),
        id('start_balance_row'),

        id('identifier_divider_row'),
        id('total_return_row'),
        id('capital_appreciation_row'),
        id('interest_row'),
        id('qualified_dividends_row'),
        id('unqualified_dividends_row'),
        id('capital_gain_distributions_row'),

        id('reinvested_interest_row'),
        id('reinvested_qualified_dividends_row'),
        id('reinvested_unqualified_dividends_row'),
        id('reinvested_capital_gain_distributions_row'),

        id('total_distributions_row'),
        id('cost_basis_divider_row'),
        id('sold_invested_row'),
        id('start_cost_basis_row'),
        id('end_cost_basis_row'),
        id('realized_gain_row'),
        id('unrealized_gain_row'),

        id('end_balance_divider_row'),
        id('end_balance_row'),
      ]
    ]
    ..implClass = (class_('t_f_holding_period_balance')
        ..defaultMemberAccess = IA
        ..ctorCustoms = ['']
        ..members = [
          member('model')..type = 'HoldingPeriodBalance',
          member('holding_table')..type = 'TableElement',
          member('composite_table')..type = 'CompositeTable',
          member('year')..isObservable = true..access = RW,
          member('account')..isObservable = true..access = RW,
          member('symbol')..isObservable = true..access = RW,
          member('component_rows')..type = 'List<CompositeRow>',
        ]),
    component('t_f_balance_sheet')
    ..imports = [
      'async',
      //'package:animation/animation.dart',
      "'package:plus/models/common.dart' hide Point",
      'package:plus/models/forecast.dart',
      'package:basic_input/formatting.dart',
      'package:plus/date.dart',
      'package:plus/date_value.dart',
      'package:plus/date_range.dart',
      'package:plus/finance.dart',
      'package:tooltip/components/tooltip.dart',
      'package:timeline_forecast/current_dollars.dart',
      'package:timeline_forecast/year_axis.dart',
      'package:timeline_forecast/composite_table.dart',
      'package:timeline_forecast/timeline_model.dart',
      't_f_holding_period_balance.dart',
    ]
    ..supportClasses = [
      class_('balance_sheet_row')
      ..defaultMemberAccess = IA
      ..extend = 'CompositeRow'
      ..members = [
      ],
      class_('holding_row')
      ..defaultMemberAccess = IA
      ..extend = 'BalanceSheetRow'
      ..members = [
        member('scenario_name'),
        member('account'),
        member('symbol'),
        member('holding_period_balance')..type = 'HoldingPeriodBalance',
        member('on_click_subscription')..type = 'StreamSubscription<MouseEvent>'..access = RO,
      ],
    ]
    ..implClass = (class_('t_f_balance_sheet')
        ..defaultMemberAccess = IA
        ..ctorCustoms = ['']
        ..members = [
          member('annual_forecast_model')..type = 'IAnnualForecastModel',
          member('balance_sheet_model')..type = 'IBalanceSheetModel',
          member('container')..type = 'HtmlElement'..access = RO,
          member('title')..isObservable = true..access = RW,
          member('period_range')..type = 'DateRange',
          member('start_date_value')..type = 'DateValue',
          member('end_date_value')..type = 'DateValue',
          member('current_dollars_toggler')..type = 'CurrentDollarsToggler',
          member('balance_sheet_table')..type = 'TableElement',
          member('composite_table')..type = 'CompositeTable',

          member('net_worth_row')..type = 'BalanceSheetRow',
          member('total_asset_row')..type = 'BalanceSheetRow',
          member('total_holding_asset_row')..type = 'HoldingRow',
          member('total_nonholding_asset_row')..type = 'BalanceSheetRow',
          member('total_liability_row')..type = 'BalanceSheetRow',
          member('reserves_row')..type = 'BalanceSheetRow',

          member('title_element')..type = 'HtmlElement',
          member('total_asset_expander')..type = 'HtmlElement',
          member('total_holding_asset_expander')..type = 'HtmlElement',
          member('total_nonholding_asset_expander')..type = 'HtmlElement',
          member('total_liability_expander')..type = 'HtmlElement',

          member('year')..isObservable = true..access = RW,
        ]),
    component('t_f_income_statement')
    ..imports = [
      'package:plus/models/forecast.dart',
      'package:plus/models/income_statement.dart',
      'package:plus/finance.dart',
      'package:basic_input/formatting.dart',
      'package:plus/date_range.dart',
      'package:timeline_forecast/current_dollars.dart',
      'package:timeline_forecast/composite_table.dart',
      'package:timeline_forecast/timeline_model.dart',
    ]
    ..implClass = (class_('t_f_income_statement')
        ..defaultMemberAccess = IA
        ..ctorCustoms = ['']
        ..members = [
          member('model')..type = 'IIncomeStatementModel',
          member('container')..type = 'HtmlElement'..access = RO,
          member('current_dollars_toggler')..type = 'CurrentDollarsToggler',
          member('income_expense_table')..type = 'TableElement',
          member('composite_table')..type = 'CompositeTable',
          member('year')..isObservable = true..access = RW,
        ]),
    component('t_f_tax_summary')
    ..imports = [
      'package:basic_input/formatting.dart',
      'package:timeline_forecast/current_dollars.dart',
      'package:timeline_forecast/composite_table.dart',
      'package:timeline_forecast/timeline_model.dart',
    ]
    ..implClass = (class_('t_f_tax_summary')
        ..defaultMemberAccess = IA
        ..ctorCustoms = ['']
        ..members = [
          member('container')..type = 'HtmlElement'..access = RO,
          member('model')..type = 'ITaxSummaryModel',
          member('current_dollars_toggler')..type = 'CurrentDollarsToggler',
          member('tax_summary_table')..type = 'TableElement',
          member('composite_table')..type = 'CompositeTable',
          member('year')..isObservable = true..access = RW,
        ]),
    component('t_f_liquidation_summary')
    ..imports = [
      'package:basic_input/formatting.dart',
      'package:plus/models/common.dart',
      'package:timeline_forecast/current_dollars.dart',
      'package:timeline_forecast/composite_table.dart',
      'package:timeline_forecast/timeline_model.dart',
    ]
    ..implClass = (class_('t_f_liquidation_summary')
        ..defaultMemberAccess = IA
        ..ctorCustoms = ['']
        ..members = [
          member('model')..type = 'ILiquidationSummaryModel',
          member('container')..type = 'HtmlElement'..access = RO,
          member('current_dollars_toggler')..type = 'CurrentDollarsToggler',
          member('liquidation_summary_table')..type = 'TableElement',
          member('composite_table')..type = 'CompositeTable',
          member('year')..isObservable = true..access = RW,
        ]),
    component('timeline_nav')
    ..doc = '''
Primary navigation container for the timeline.

It models the timeline for one or more Timeline models (each which just wraps a
MultiYearForecast and pulls out some data) instances (It contains one or more
TimelineView instances, each focused on one or more models.

'''
    ..imports = [
      'timeline.dart',
      'timeline_header.dart',
      'package:timeline_forecast/timeline_model.dart',
    ]
    ..implClass = (class_('timeline_nav')
        ..defaultMemberAccess = IA
        ..members = [
          member('shell_div')..type = 'DivElement',
          member('timeline_header')..type = 'TimelineHeader',
          member('timeline_component')..type = 'Timeline',
          member('comparison_model')..type = 'TimelineComparisonModel',
        ]),
    component('timeline_header')
    ..imports = [
      'package:timeline_forecast/timeline_enums.dart',
      't_f_annual_component_toggler.dart',
      't_f_nav_content_selector.dart',
    ]
    ..implClass = (class_('timeline_header')
        ..defaultMemberAccess = IA
        ..members = [
          member('annual_component_toggler')..type = 'TFAnnualComponentToggler',
          member('nav_content_selector')..type = 'TFNavContentSelector',
        ])
    ..doc = '''Displays the current active display type (Net Worth, Total Assets, ... ), allowing users to switch between'''
    ,
    component('timeline')
    ..imports = [
      "'dart:svg' hide Point",
      "'dart:svg' as svg show Point",
      "'dart:math' show min, max, Point",
      'async',
      '"package:quiver/iterables.dart" hide min, max',
      'package:basic_input/formatting.dart',
      'package:timeline_forecast/timeline_enums.dart',
      'package:timeline_forecast/timeline_model.dart',
      'package:timeline_forecast/current_dollars.dart',
      'package:plus/date.dart',
      't_f_annual_forecast.dart',
      't_f_balance_sheet.dart',
      't_f_income_statement.dart',
      't_f_tax_summary.dart',
      't_f_liquidation_summary.dart',
      'package:plus/date_range.dart',
    ]
    ..supportClasses = [
      class_('visual')
      ..doc = 'Packages the visual element and the value it represents'
      ..members = [
        member('value')..classInit = 0.0..ctors = [''],
        member('element')..type = 'Element'..ctors = [''],
      ],
      class_('net_worth_visual')
      ..extend = 'Visual'
      ..members = [ ],
      class_('total_asset_visual')
      ..extend = 'Visual'
      ..members = [ ],
      class_('total_liability_visual')
      ..extend = 'Visual'
      ..members = [ ],

      class_('net_income_visual')
      ..extend = 'Visual'
      ..members = [ ],
      class_('total_income_visual')
      ..extend = 'Visual'
      ..members = [ ],
      class_('total_expense_visual')
      ..extend = 'Visual'
      ..members = [ ],

      class_('visuals_in_year')
      ..doc = 'The visuals within a year'
      ..members = [
        member('year')..classInit = 0..ctors = [''],
        member('visuals')..type = 'Map<String, Visual>'..classInit = {},
      ],
      class_('visuals_for_display_type')
      ..doc = 'Manages all visuals of a single display type'
      ..ctorCustoms = ['']
      ..members = [
        member('display_type')..type = 'DisplayType'..ctors = [''],
        member('start_year')..classInit = 0..ctors = [''],
        member('num_years')..classInit = 0..ctors = [''],
        member('min_label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('max_label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('min_value')..type = 'double'..classInit = 'double.MAX_FINITE',
        member('max_value')..type = 'double'..classInit = '-double.MAX_FINITE',
        member('group')..type = 'GElement'..classInit = 'new GElement()',
        member('visuals_by_year')..type = 'List<VisualsInYear>',
        member('legend_label_font_size')..isStatic = true..classInit = 10.0..access = RO,
      ],
      class_('year_elements')
      ..isPublic = false
      ..ctorCustoms = ['']
      ..members = [
        member('year')..classInit = 0..ctors = [''],
        member('x')..classInit = 0.0,
        member('vertical_line')..type = 'LineElement'..classInit = 'new LineElement()',
        member('year_top_label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('year_bottom_label')..type = 'TextElement'..classInit = 'new TextElement()',
        member('year_label_font_size')..isStatic = true..classInit = 14.0..access = RO,
      ],
    ]
    ..implClass = (class_('timeline')
        ..doc = '''
Primary display for multi-year forecast.

Can show one or more models perview.
'''
        ..defaultMemberAccess = IA
        ..members = [
          member('comparison_model')..type = 'TimelineComparisonModel',
          member('date_range')
          ..doc = 'Range of the forecasts - it is assumed all forecasts are on the same range'
          ..type = 'DateRange',

          member('svg_container')..type = 'SvgSvgElement'..classInit = 'new SvgSvgElement()',
          member('annual_forecasts_container')..type = 'DivElement',

          member('shell_div')..type = 'DivElement',
          member('highlight_rect')..type = 'RectElement'
          ..classInit = 'new RectElement()',
          member('point')..type = 'svg.Point',
          member('origin')..doc = 'Starting offset for the axis within svg'
          ..type = 'Point'..classInit = 'new Point(0.0,0.0)',
          member('origin_offset')
          ..type = 'Point'..classInit = 'new Point(0.0,0.0)',
          member('inner_margin')..type = 'Point'
          ..classInit = 'new Point(55.0,15.0)'..access = RO,
          member('display_width')..classInit = 650.0..access = RO,
          member('display_height')..classInit = 150.0..access = RO,
          member('year_label_height')..classInit = 14.0..access = RO,
          member('label_to_line_margin')..classInit = 4.0..access = RO,

          member('num_years')..classInit = 0,
          member('start_year')..classInit = 0,
          member('focus_year')..classInit = 0
          ..doc = 'Year in the timeline which is the current focus',
          member('year_width')..classInit = 0.0,
          member('common_group')..type = 'GElement'..classInit = 'new GElement()'
          ..doc = 'Group containing all elements that do not change when swapping display (eg topLine, bottomLine, year labels,...)',
          member('year_elements_group')..type = 'GElement'..classInit = 'new GElement()'
          ..doc = 'Model dependent group containing elements that vary by year',
          member('visuals_group')..type = 'GElement'..classInit = 'new GElement()',
          member('top_line')..type = 'LineElement'..classInit = 'new LineElement()',
          member('bottom_line')..type = 'LineElement'..classInit = 'new LineElement()',
          member('year_elements')..type = 'List<_YearElements>'..classInit = [],
          member('visuals_by_display_type')..type = 'Map<DisplayType, VisualsForDisplayType>'..classInit = {},
        ]),
  ]
  ..finalize();

main() => timeline_components.generate();
