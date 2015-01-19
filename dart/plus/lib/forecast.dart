library plus.forecast;

import 'dart:math';
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/logging.dart';
import 'package:plus/map_utilities.dart';
import 'package:plus/models/assumption.dart';
import 'package:plus/models/balance_sheet.dart';
import 'package:plus/models/common.dart';
import 'package:plus/models/dossier.dart';
import 'package:plus/models/flow_model.dart';
import 'package:plus/models/forecast.dart';
import 'package:plus/models/income_statement.dart';
import 'package:plus/models/liquidation_summary.dart';
import 'package:plus/portfolio.dart';
import 'package:plus/strategy.dart';
import 'package:quiver/iterables.dart' hide min, max;
// custom <additional imports>
// end <additional imports>

part 'src/forecast/grid_info.dart';
part 'src/forecast/grid.dart';

final _logger = new Logger('forecast');

// custom <library forecast>
// end <library forecast>

