library plus.bin.dart_libs.forecast;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

var _commonImports = [
  'math',
  'package:plus/forecast.dart',
  'package:plus/date.dart',
  'package:plus/date_value.dart',
  'package:plus/date_range.dart',
  'package:plus/test_utils.dart',
  'package:plus/models/balance_sheet.dart',
];

List<Library> get testLibs =>[
  testLibrary('test_forecast_grid')
  ..imports.addAll(_commonImports),
  testLibrary('test_forecast')
  ..imports.addAll(_commonImports),
];

Library get lib => library('forecast')
  ..includeLogger = true
  ..imports.addAll([
    'math',
    "'package:quiver/iterables.dart' hide min, max",
    'package:plus/date.dart',
    'package:plus/date_value.dart',
    'package:plus/date_range.dart',
    'package:basic_input/formatting.dart',
    'package:plus/logging.dart',
    'package:plus/map_utilities.dart',
    'package:plus/finance.dart',
    'package:plus/portfolio.dart',
    'package:plus/strategy.dart',
    'package:plus/models/common.dart',
    'package:plus/models/assumption.dart',
    'package:plus/models/dossier.dart',
    'package:plus/models/balance_sheet.dart',
    'package:plus/models/forecast.dart',
    'package:plus/models/flow_model.dart',
    'package:plus/models/income_statement.dart',
    'package:plus/models/liquidation_summary.dart',
  ])
  ..benchmarks = [
    benchmark('grid_creation'),
    benchmark('cflow_expand'),
    benchmark('lower_bound'),
    benchmark('grid_timeline_creation'),
  ]
  ..parts = [
    part('grid_info')
    ..doc = 'Info related classes used by the grid'
    ..classes = [
      class_('account_info')
      ..immutable = true
      ..members = [
        member('account_name'),
        member('portfolio_account')..type = 'PortfolioAccount',
        member('start_index')..doc = 'Start index into holding infos for this account'..classInit = 0,
        member('end_index')..doc = 'Start index into holding infos for this account'..classInit = 0,
      ],
      class_('holding_info')
      ..immutable = true
      ..members = [
        member('holding_key')..type = 'HoldingKey',
        member('holding')..type = 'Holding',
        member('curves_attribution')..type = 'CurvesAttribution',
        member('reinvestment_policy')..type = 'ReinvestmentPolicy',
        member('instrument_partitions')..type = 'InstrumentPartitions',
        member('distance_to_target')..type = 'double',
      ],
      class_('asset_info')
      ..doc = 'Wraps asset name and type'
      ..immutable = true
      ..members = [
        member('name'),
        member('asset')..type = 'Asset',
        member('growth')..type = 'RateCurve',
      ],
      class_('liability_info')
      ..doc = 'Wraps liability name and type'
      ..immutable = true
      ..members = [
        member('name'),
        member('liability')..type = 'Liability',
        member('growth')..type = 'RateCurve',
      ],
      class_('income_info')
      ..members = [
        member('name')..ctors = ['']..isFinal = true,
        member('income_spec')..type = 'IncomeSpec'..ctors = ['']..isFinal = true,
        member('flow_details')..type = 'List<FlowDetail>'..ctors = ['']..isFinal = true,
      ],
      class_('expense_info')
      ..members = [
        member('name')..ctors = ['']..isFinal = true,
        member('expense_spec')..type = 'ExpenseSpec'..ctors = ['']..isFinal = true,
        member('flow_details')..type = 'List<FlowDetail>'..ctors = ['']..isFinal = true,
      ],
    ],
    part('grid')
    ..classes = [
      class_('forecast_grid')
      ..defaultMemberAccess = IA
      ..members = [
        member('dossier')..type = 'Dossier'..isFinal = true,
        member('track_details')..classInit = false,
        member('complete_year_range')
        ..doc = '''
Range of forecast - *Note* range is user requested range plus additional year
prior to requested start in order to bring assets, liabilities, holdings
up to date for the specified start.
'''
        ..type = 'YearRange',
        member('complete_date_range')
        ..doc = 'Date range where the first year precedes the year of the forecast'
        ..type = 'DateRange'..access = RO,
        member('assumption_model')..type = 'AssumptionModel',
        member('balance_sheet_assumptions')..type = 'BalanceSheetAssumptions',
        member('income_preferred_links')..type = 'Map<FlowKey,List<int>>',
        member('expense_preferred_links')..type = 'Map<FlowKey,List<int>>',
        member('preferred_expense_sources')..type = 'Map<ExpenseType,List<int>>',
        member('income_holdings')..type = 'List<int>',
        member('expense_holdings')..type = 'List<int>',
        member('holding_distances')..type = 'List<HoldingDistance>',
        member('date_range')..type = 'DateRange'..access = RO,
        member('grid_years')..type = 'List<GridYear>',
        member('account_infos')..type = 'List<AccountInfo>',
        member('holding_infos')..type = 'List<HoldingInfo>',
        member('asset_infos')..type = 'List<AssetInfo>',
        member('liability_infos')..type = 'List<LiabilityInfo>',
        member('reserve_shortfall_rate')..type = 'RateCurve',
        member('reserve_excess_rate')..type = 'RateCurve',

        member('flow_model')..type = 'FlowModel',
        member('income_infos')..type = 'List<IncomeInfo>'..access = RO,
        member('expense_infos')..type = 'List<ExpenseInfo>'..access = RO,

        member('current_grid_year')..type = 'GridYear',
        member('prev_grid_year')..type = 'GridYear',
        member('period_end')..type = 'Date',
        member('prev_period_end')..type = 'Date',
        member('period_date_range')..type = 'DateRange',
        member('flows_processed')..classInit = 0,
        member('tax_rate_assumptions')..type = 'TaxRateAssumptions',
      ],
      class_('holding_distance')
      ..comparable = true
      ..members = [
        member('distance')..type = 'double',
        member('index')..type = 'int',
      ],
      class_('tax_breakdown')
      ..courtesyCtor = true
      ..doc = 'Set of taxable items tracked - values depend on context'
      ..members = [
        member('pension')..classInit = 0.0,
        member('social_security')..classInit = 0.0,
        member('rental')..classInit = 0.0,
        member('labor')..classInit = 0.0,
        member('capital_gain')..classInit = 0.0,
        member('qualified_dividends')..classInit = 0.0,
        member('unqualified_dividends')..classInit = 0.0,
        member('capital_gain_distributions')..classInit = 0.0,
        member('interest')..classInit = 0.0,
      ],
      class_('grid_year')
      ..members = [
        member('year')..type = 'int',
        member('start_date')..type = 'Date',
        member('end_date')..type = 'Date',
        member('grid_holdings')..type = 'List<GridHolding>',
        member('asset_balances')..type = 'List<GridBalance>',
        member('liability_balances')..type = 'List<GridBalance>',
        member('flow_details')..type = 'List<FlowDetail>'..classInit = [],
        member('forecast_details')..type = 'ForecastDetails',
        member('distribution_summary')..type = 'DistributionSummary'
        ..classInit = 'new DistributionSummary.empty()',
        member('untargeted_net_flow')..classInit = 0.0,
        member('reserves')..type = 'GridBalance',
        member('taxable_income_breakdown')..type = 'TaxBreakdown'
        ..classInit = 'new TaxBreakdown.empty()',
        member('tax_bill')..type = 'TaxBreakdown',
      ],
      class_('flow_account_link')
      ..immutable = true
      ..members = [
        member('flow_detail')..type = 'FlowDetail',
        member('flow_allocation')
        ..doc = 'From the flow, the amount allocated to the holding'
        ..type = 'double',
        member('holding_key')..type = 'HoldingKey',
      ],
      class_('forecast_details')
      ..members = [
        member('flow_account_links')..type = 'List<FlowAccountLink>'..classInit = [],
      ],
      class_('grid_holding')
      ..members = [
        member('holding_key')..type = 'HoldingKey',
        member('reinvestment_policy')..type = 'ReinvestmentPolicy',
        member('distributions_sheltered')..classInit = false,
        member('can_capital_gain_be_sheltered')..classInit = false,
        member('prev_balance')..type = 'double'..classInit = 0.0,
        member('full_balance')..classInit = 0.0,
        member('growth_attribution')
        ..doc = 'Details on modeled growth from start to end - (does *not* including sales/investments)'
        ..type = 'Attribution',
        member('net_trade')..classInit = 0.0,
        member('distributed_distributions')..type = 'DistributionBreakdown'
        ..classInit = 'new DistributionBreakdown.empty()',
        member('reinvested_distributions')..type = 'DistributionBreakdown'
        ..classInit = 'new DistributionBreakdown.empty()',
        member('sheltered_distributions')..type = 'DistributionBreakdown'
        ..classInit = 'new DistributionBreakdown.empty()',
        member('avg_cost_accumulator')..type = 'AvgCostAccumulator',
        member('unsheltered_capital_gain')..type = 'double'..classInit = 0.0,
        member('sheltered_capital_gain')..type = 'double'..classInit = 0.0,
      ],
      class_('grid_balance')
      ..members = [
        member('prev_balance')..type = 'double'..classInit = 0.0,
        member('balance')..type = 'double'..classInit = 0.0,
      ],
    ]
  ];

get libs => [ lib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);