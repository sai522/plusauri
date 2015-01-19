part of plus.repository;

// custom <part curves>

class _Curves {

  final _inflation = alternating(0.03, 0.005);
  get inflation => _inflation;

  get usageDepreciation => rateCurve([ dv(date(1900,1,1), -0.015) ]);

  get partTimeLaborGrowth => rateCurve([ dv(date(1900,1,1), 0.018) ]);

  get fullTimeLaborGrowth => rateCurve([ dv(date(1900,1,1), 0.035) ]);

  get caymanPorsche => rateCurve([ dv(date(1900,1,1), 0.022) ]);

  get dreamCarLoan => rateCurve([ dv(date(1900,1,1), 0.055) ]);

  get mortgageLoan => rateCurve([ dv(date(1900,1,1), 0.045) ]);

  final _stockReturn = alternating(0.055, 0.005);
  get stockReturn => _stockReturn;

  final _riskyStockReturn = alternating(0.085, 0.005);
  get riskyStockReturn => _riskyStockReturn;

  get bondReturn => rateCurve([ dv(date(1900,1,1), 0.031) ]);

  final _conservativeStockReturn = alternatingWithShock(0.035, 0.005);
  get conservativeStockReturn => _conservativeStockReturn;

  final _stockDivReturn = alternating(0.015, 0.001);
  get stockDivReturn => _stockDivReturn;

  final _qualifiedDivReturn = alternating(0.008, 0.001);
  get qualifiedDivReturn => _qualifiedDivReturn;

  final _unqualifiedDivReturn = alternating(0.015, 0.001);
  get unqualifiedDivReturn => _unqualifiedDivReturn;

  final _moneyMarketInterest = alternating(0.0075, 0.0001);
  get moneyMarketInterest => _moneyMarketInterest;

  final _capitalGainDistribution = alternating(0.0002, 0.00005);
  get capitalGainDistribution => _capitalGainDistribution;

  final _reservesIncome = alternating(0.002, 0.0001);
  get reservesIncome => _reservesIncome;

  final _reservesExpense = alternating(-0.01, 0.0001);
  get reservesExpense => _reservesExpense;

  get eliteCollegeCostIncreases => rateCurve([
    dv(date(1900,1,1), 0.055),
    dv(date(2000,1,1), 0.065),
    dv(date(2013,1,1), 0.055),
    dv(date(2018,1,1), 0.045),
    dv(date(2025,1,1), 0.04),
  ]);

  get stateCollegeCostIncreases => rateCurve([
    dv(date(1900,1,1), 0.055),
    dv(date(2000,1,1), 0.045),
    dv(date(2018,1,1), 0.04),
  ]);

  get all => {
    'inflation' : inflation,
    'usageDepreciation' : usageDepreciation,
    'partTimeLaborGrowth' : partTimeLaborGrowth,
    'fullTimeLaborGrowth' : fullTimeLaborGrowth,
    'caymanPorsche' : caymanPorsche,
    'dreamCarLoan' : dreamCarLoan,
    'mortgageLoan' : mortgageLoan,
    'bondReturn' : bondReturn,
    'stockReturn' : stockReturn,
    'riskyStockReturn' : riskyStockReturn,
    'conservativeStockReturn' : conservativeStockReturn,
    'stockDivReturn' : stockDivReturn,
    'qualifiedDivReturn' : qualifiedDivReturn,
    'unqualifiedDivReturn' : unqualifiedDivReturn,
    'reservesIncome' : reservesIncome,
    'reservesExpense' : reservesExpense,
  };

}

int _startYear = 1990;
int _endYear = 2120;

RateCurve alternatingWithShock(double rate, double delta) {
  List<DateValue> result = new List(_endYear - _startYear);
  for(int i=_startYear; i<_endYear; i++) {
    final current = startOfYear(i);
    if(current.year == 2025) {
      result[i-_startYear] = new DateValue(current,
          -3.0*rate);
    } else if(current.year == 2032) {
      result[i-_startYear] = new DateValue(current,
          3.0*rate);
    } else {
      result[i-_startYear] = new DateValue(current,
          rate + (i%2)*delta);
    }
  }
  return new RateCurve(result);
}

RateCurve alternating(double rate, double delta) {
  List<DateValue> result = new List(_endYear - _startYear);
  for(int i=_startYear; i<_endYear; i++) {
    final current = startOfYear(i);
    result[i-_startYear] = new DateValue(current,
        rate + (i%2)*delta);
  }
  return new RateCurve(result);
}

var _curves = new _Curves();
var curves = _curves;

// end <part curves>
