library ignored.all_schema;

import 'plus_system.dart';
import 'root_path.dart';
import 'json_schema/assumption.dart';
import 'json_schema/balance_sheet.dart';
import 'json_schema/common.dart';
import 'json_schema/dossier.dart';
import 'json_schema/flow_model.dart';
import 'json_schema/forecast.dart';
import 'json_schema/income_statement.dart';
import 'json_schema/liquidation_summary.dart';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:ebisu/ebisu_utils.dart';
import 'package:json_schema/schema_dot.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:simple_schema/simple_schema.dart';
import 'package:simple_schema/simple_schema_dart.dart' as dart_gen;
import 'dart:io';

String _rootPath = rootPath;
String _output = join(_rootPath, 'schema_output');
String _libPath = join(_rootPath, 'lib');
String _modelsPath = join(_libPath, 'models');

final noDefaultCtorSet = new Set.from(['dateRange']);
final opEqualsSet = new Set.from(['dividendSummary', 'periodBalance']);

setImmutableDefaults(Class klass, { bool builder : false, bool comparable : false }) =>
  klass..comparable = comparable..immutable = true..builder = builder..ctorSansNew = false;

final enumCustomizations = {
  'expenseType' : (e) => e..hasCustom = true,
};

final customizations = {
  'accountBalance' : (klass) => setImmutableDefaults(klass),
  'accountSet': (klass) => setImmutableDefaults(klass),
  'accountAssumptions' : (klass) => setImmutableDefaults(klass),
  'allocationPartition' : (klass) => setImmutableDefaults(klass),
  'annualForecast' : (klass) => setImmutableDefaults(klass),
  'assetKey' : (klass) => setImmutableDefaults(klass)..polymorphicComparable = true..cacheHash=true..jsonToString=false..implement.add('FundingKey'),
  'assumptionModel' : (klass) => setImmutableDefaults(klass, builder:true)..ctorCallsInit = true,
  'balanceSheet' : (klass) => setImmutableDefaults(klass)..jsonToString = false
      ..members.add(member('accounts_by_type')
          ..type = 'Map<AccountType,List<String>>'
          ..access = IA
          ..jsonTransient = true)
      ..members.add(member('holding_keys')
          ..type = 'List<HoldingKey>'
          ..access = IA
          ..jsonTransient = true),
  'balanceSheetAssumptions' : (klass) => setImmutableDefaults(klass, builder:true),
  'capitalizationPartition' : (klass) => setImmutableDefaults(klass),
  'costBasis' : (klass) => setImmutableDefaults(klass)..ctorCallsInit = true,
  'dossier' : ((klass) => setImmutableDefaults(klass, builder:true)
      ..members.add(member('income_preferred_links')
          ..type = 'Map<String,List<HoldingKey>>'
          ..access = IA
          ..jsonTransient = true)
      ..members.add(member('expense_preferred_links')
          ..type = 'Map<String,List<HoldingKey>>'
          ..access = IA
          ..jsonTransient = true)
      ..members.add(member('preferred_expense_sources')
          ..doc = 'Preferred source based on busines rules (eg College Expense paid by College Accounts)'
          ..type = 'Map<ExpenseType,List<HoldingKey>>'
          ..access = IA
          ..jsonTransient = true)
      ..members.add(member('income_holding_keys')
          ..doc = 'List of sources that have not been covered by incomePreferredLinks'
          ..type = 'List<HoldingKey>'
          ..access = IA
          ..jsonTransient = true)
      ..members.add(member('expense_holding_keys')
          ..doc = 'List of sources that have not been covered by expensePreferredLinks or preferredExpenseSources'
          ..type = 'List<HoldingKey>'
          ..access = IA
          ..jsonTransient = true)),
  'distributionBreakdown' : (klass) => klass..courtesyCtor = true..defaultCtor = false,
  'distributionSummary' : (klass) => klass..courtesyCtor = true..defaultCtor = false,
  'expenseFlows' : (klass) => setImmutableDefaults(klass),
  'expenseSpec' : (klass) => setImmutableDefaults(klass),
  'flowDetail' : (klass) => setImmutableDefaults(klass)
  ..implement = ['Comparable<FlowDetail>']
  ..members.add(member('flow_key')..type = 'FlowKey'..access=IA..jsonTransient = true)..jsonToString = false,
  'flowEntry' : (klass) => setImmutableDefaults(klass)..builder = true,
  'flowKey' : (klass) => setImmutableDefaults(klass),
  'flowModel' : (klass) => setImmutableDefaults(klass)
  ..members.add(member('income_keys')
      ..type = 'List<FlowKey>'
      ..access=IA..jsonTransient = true)
  ..members.add(member('expense_keys')
      ..type = 'List<FlowKey>'
      ..access=IA..jsonTransient = true),
  'flowSpec' : (klass) => setImmutableDefaults(klass),
  'fundingAdjustment' : (klass) => setImmutableDefaults(klass),
    //  'fundingKey' : (klass) => setImmutableDefaults(klass)..implement = ['Comparable<FundingKey>']..opEquals = false..jsonToString=false,
  'holding' : (klass) => setImmutableDefaults(klass),
  'holdingAssumptions' : (klass) => setImmutableDefaults(klass),
  'holdingKey' : (klass) => setImmutableDefaults(klass)..comparable = true..cacheHash=true..jsonToString=false,
  'holdingPeriodBalance' : (klass) => setImmutableDefaults(klass),
  'holdingReturns' : (klass) => setImmutableDefaults(klass),
  'incomeFlows' : (klass) => setImmutableDefaults(klass),
  'incomeSpec' : (klass) => setImmutableDefaults(klass),
  'instrumentAssumptions' : (klass) => setImmutableDefaults(klass),
  'instrumentPartitions' : (klass) => setImmutableDefaults(klass),
  'investmentStylePartition' : (klass) => setImmutableDefaults(klass),
  'liabilityKey' : (klass) => setImmutableDefaults(klass)..comparable = true..cacheHash=true..jsonToString=false,
  'liquidationSummary' : (klass) => setImmutableDefaults(klass),
  'partitionMapping' : (klass) => setImmutableDefaults(klass),
  'periodBalanceSheet' : (klass) => setImmutableDefaults(klass, builder:true),
  'point' : (klass) => setImmutableDefaults(klass),
  'portfolioAccount' : (klass) => setImmutableDefaults(klass, builder:true),
  'realizedFlows' : (klass) => setImmutableDefaults(klass)..jsonToString = false,
  'reserveAssumptions' : (klass) => setImmutableDefaults(klass),
  'reinvestmentPolicy' : (klass) => setImmutableDefaults(klass),
  'taxRateAssumptions' : (klass) => setImmutableDefaults(klass),
    //..members.add(member('funding_user_preferences')..access=IA..jsonTransient = true)
    //..members.add(member('investment_user_preferences')..access=IA..jsonTransient = true),
};


dartLib(Package package) {
  final result = dart_gen.makeLibraryFromSimpleSchema
    (package,
        // These overrides are 'declared' in common (defined in code)
        overrideImports : {
          'double' : null,
          'dynamic' : null,
          'date' : 'package:plus/date.dart',
          'dateRange' : 'package:plus/date_range.dart',
          'dateValue' : 'package:plus/date_value.dart',
          'rateCurve' : 'package:plus/finance.dart',

          'allocationType' : 'package:plus/finance.dart',
          'capitalizationType' : 'package:plus/finance.dart',
          'investmentStyle' : 'package:plus/finance.dart',

          'timeSeries' : 'package:plus/time_series.dart',
          'trade' : 'package:plus/portfolio.dart',
          'tradeJournal' : 'package:plus/portfolio.dart',
        },
        noDefaultCtorSet : noDefaultCtorSet,
        opEqualsSet : opEqualsSet
     )
  ..path = _modelsPath;

  result.classes.forEach((Class klass) {
    final customizer = customizations['${klass.id}'];
    if(customizer != null) {
      customizer(klass);
    }
  });

  result.enums.forEach((e) {
    final customizer = enumCustomizations['${e.id}'];
    if(customizer != null) {
      customizer(e);
    }
  });

  return result;
}

dartSupport(Package package) =>
  dartLib(package)..generate();

diagramSupport(Package pkg) {
  var name = pkg.id.snake;
  return pkg
    .schema
    .then((schema) {
      var jsonPath = join(_output, '${name}.json');
      var outPath = join(_output, '${name}.dot');
      mergeWithFile(prettyJsonMap(schema.schemaMap), jsonPath);
      mergeWithFile(createDot(schema), outPath);
      return outPath;
    })
    .then((outPath) {
      var pngPath = join(dirname(outPath), '$name.png');
      var pdfPath = join(dirname(outPath), '$name.pdf');
      var svgPath = join(dirname(outPath), '$name.svg');
      return Process.run('dot', ['-Tpng', '-o$pngPath', '$outPath'])
        .then((ProcessResult processResult) {
          if(processResult.exitCode == 0) {
            print("Finished running dot -Tpng -o$pngPath $outPath");
          } else {
            print("FAILED: running dot -Tpng -o$pngPath $outPath");
          }
        })
        .then((_) =>
            Process.run('dot', ['-Tsvg', '-o$svgPath', '$outPath'])
            .then((ProcessResult processResult) {
              if(processResult.exitCode == 0) {
                print("Finished running dot -Tsvg -o$svgPath $outPath");
              } else {
                print("FAILED: running dot -Tsvg -o$svgPath $outPath");
              }
            }))
        .then((_) =>
            Process.run('dot', ['-Tpdf', '-o$pdfPath', '$outPath'])
            .then((ProcessResult processResult) {
              if(processResult.exitCode == 0) {
                print("Finished running dot -Tpdf -o$pdfPath $outPath");
              } else {
                print("FAILED: running dot -Tpdf -o$pdfPath $outPath");
              }
            }));
    });
}

modelSupport(Package package) {
  dartSupport(package);
}

var _models = [
  assumption, balanceSheet, common, dossier, flowModel,
  forecast, incomeStatement, liquidationSummary
];


final _allDartSchemaLibs =
  _models.map((model) => dartLib(model)).toList();

get models => _models;
get libs => _allDartSchemaLibs;
get testLibs => libs.map((l) =>
    library('test_model_${l.id.snake}')
    ..isTest = true);

main() {

  final schemaLibs = libs;

  plus
    ..libraries.addAll(schemaLibs)
    ..testLibraries.addAll(testLibs)
    ..generate(generateHop:false);
  
  models.forEach((Package model) {
    //modelSupport(model);

    //diagramSupport(model);
  });
  
}
