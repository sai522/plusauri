library timeline_forecast.current_dollars;

import 'package:plus/date.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
// custom <additional imports>
// end <additional imports>

class CurrentDollarsToggler {
  CurrentDollarsToggler(this._today, this._inflation);

  Date get today => _today;
  RateCurve get inflation => _inflation;
  bool get showingCurrentDollars => _showingCurrentDollars;
  // custom <class CurrentDollarsToggler>

  toggle() => _showingCurrentDollars = !_showingCurrentDollars;

  showDollarsPair(Date date, double value) => _showingCurrentDollars
      ? value * _inflation.scaleFromTo(date, today)
      : value;

  showDollars(DateValue dv) => showDollarsPair(dv.date, dv.value);

  // end <class CurrentDollarsToggler>
  Date _today;
  RateCurve _inflation;
  bool _showingCurrentDollars = false;
}

// custom <library current_dollars>
// end <library current_dollars>
