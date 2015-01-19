part of plus.repository;

// custom <part flow_models>

class _IncomeSpecs {

  get partTimeJob =>
      new IncomeSpec(
          IncomeType.LABOR_INCOME,
          new FlowSpec("Grocery store job", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2010, 1, 1), date(2020, 1, 1))
      ..growth = _curves.partTimeLaborGrowth
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..initialValue = dv(date(2013, 1, 1), 25000.0)));

  get fullTimeJob =>
      new IncomeSpec(
          IncomeType.LABOR_INCOME,
          new FlowSpec("Pharmacy store job", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2010, 1, 1), date(2025, 1, 1))
      ..growth = _curves.fullTimeLaborGrowth
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..initialValue = dv(date(2013, 1, 1), 80000.0)));

  get pensionIncome =>
      new IncomeSpec(
          IncomeType.PENSION_INCOME,
          new FlowSpec("Small pension", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2020, 1, 1), date(2030, 1, 1))
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..initialValue = dv(date(2013, 1, 1), 9000.0)));

  get all => {
    'partTimeJob': partTimeJob,
    'fullTimeJob': fullTimeJob,
    'pensionIncome': pensionIncome,
  };
}

class _ExpenseSpecs {

  get middleClassLifeGross =>
      new ExpenseSpec(
          ExpenseType.LIVING_EXPENSE,
          new FlowSpec("The cost of living", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(1990, 1, 1), date(2060, 1, 1))





          //                               ..paymentFrequency = PaymentFrequency.MONTHLY
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..growth = _curves.inflation
      ..initialValue = dv(date(2013, 1, 1), 90000.0)));

  get economicChildCollege =>
      new ExpenseSpec(
          ExpenseType.COLLEGE_EXPENSE,
          new FlowSpec("State school", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2017, 1, 1), date(2021, 1, 1))
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..growth = _curves.stateCollegeCostIncreases
      ..initialValue = dv(date(2013, 1, 1), 15000.0)));

  get smartChildCollege =>
      new ExpenseSpec(
          ExpenseType.COLLEGE_EXPENSE,
          new FlowSpec("Private school", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2019, 1, 1), date(2023, 1, 1))
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..growth = _curves.eliteCollegeCostIncreases
      ..initialValue = dv(date(2013, 1, 1), 40000.0)));

  get childAthleteCollege =>
      new ExpenseSpec(
          ExpenseType.COLLEGE_EXPENSE,
          new FlowSpec("Private school", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2022, 1, 1), date(2026, 1, 1))
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..initialValue = dv(date(2013, 1, 1), 400.0)));

  get palimony =>
      new ExpenseSpec(
          ExpenseType.ALIMONY,
          new FlowSpec("Ex-wife-1", "source", cFlowSequenceSpec()
      ..dateRange = dateRange(date(2013, 1, 1), date(2018, 1, 1))
      ..paymentFrequency = PaymentFrequency.ANNUAL
      ..growth = _curves.inflation
      ..initialValue = dv(date(2013, 1, 1), 10000.0)));

  get all => {
    'middleClassLifeGross': middleClassLifeGross,
    'economicChildCollege': economicChildCollege,
    'smartChildCollege': smartChildCollege,
    'childAthleteCollege': childAthleteCollege,
    'palimony': palimony,
  };
}

var _incomeSpecs = new _IncomeSpecs();
var _expenseSpecs = new _ExpenseSpecs();

class _FlowModels {
  get middleIncome => new FlowModel({
    'fullTimeJob': _incomeSpecs.fullTimeJob,
    'partTimeJob': _incomeSpecs.partTimeJob,
  }, {
    'economicChildCollege': _expenseSpecs.economicChildCollege,
    'palimony': _expenseSpecs.palimony,
    'middleClassLife': _expenseSpecs.middleClassLifeGross,
  });

  get all => {
    'middleIncome': middleIncome,
  };
}

var _flowModels = new _FlowModels();


// end <part flow_models>

