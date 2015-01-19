library plus.repository;

import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/models/balance_sheet.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/models/flow_model.dart';
import 'package:plus/models/forecast.dart';
import 'package:plus/models/income_statement.dart';
// custom <additional imports>

import 'dart:convert';

// end <additional imports>

part 'src/repository/people.dart';
part 'src/repository/curves.dart';
part 'src/repository/assumptions.dart';
part 'src/repository/balance_sheets.dart';
part 'src/repository/flow_models.dart';
part 'src/repository/dossiers.dart';

class Repository {
  // custom <class Repository>

  Repository._();

  get people => _people;
  get curves => _curves;
  get assets => _assets;
  get liabilities => _liabilities;
  get incomeSpecs => _incomeSpecs;
  get expenseSpecs => _expenseSpecs;
  get balanceSheets => _balanceSheets;
  get dossiers => _dossiers;

  // end <class Repository>
}

Repository repository = new Repository._();
// custom <library repository>

main() {
  /*
  print("Repository\n$repository");
  print(repository.people.all);
  print(repository.curves.all);
  print(repository.assets.all);
  print(repository.liabilities.all);
  print(repository.incomeSpecs.all);
  print(repository.expenseSpecs.all);
  print(repository.balanceSheets.all);
  print(repository.dossiers.all);
  */
}

// end <library repository>
