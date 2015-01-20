part of plus.repository;

// custom <part balance_sheets>

class _Assets {
  get cottage => (asset()
    ..assetType = AssetType.PRIMARY_RESIDENCE
    ..bSItem = (bSItem()
      ..descr = 'Small cottage'
      ..acquired = dateValue(date(2000, 1, 1), 209999.99)
      ..currentValue = dateValue(date(2010, 1, 1), 225009.99)));

  get fiveFourAndADoor => (asset()
    ..assetType = AssetType.PRIMARY_RESIDENCE
    ..bSItem = (bSItem()
      ..descr = 'Five/Four and a Door house'
      ..acquired = dv(date(2000, 1, 1), 325000.0)
      ..currentValue = dv(date(2010, 1, 1), 375000.0)));

  get vwFox => (asset()
    ..assetType = AssetType.AUTOMOBILE
    ..bSItem = (bSItem()
      ..descr = 'Volkswagon Fox'
      ..acquired = dateValue(date(2000, 1, 1), 16500.0)));

  get caymanPorsche => (asset()
    ..assetType = AssetType.AUTOMOBILE
    ..bSItem = (bSItem()
      ..descr = 'Cayman Porsche'
      ..acquired = dateValue(date(2000, 1, 1), 85500.0)));

  get farmLand => (asset()
    ..assetType = AssetType.INVESTMENT
    ..bSItem = (bSItem()
      ..descr = 'Some acreage in TN'
      ..acquired = dateValue(date(1989, 1, 1), 1)));

  get term500K => (asset()
    ..assetType = AssetType.INVESTMENT
    ..bSItem = (bSItem()
      ..descr = r'$500,000 worth of term life insurance'
      ..acquired = dateValue(date(1989, 1, 1), 500.0)));

  get rainyDayFund => (asset()
    ..assetType = AssetType.SAVINGS
    ..bSItem = (bSItem()
      ..descr = r'Money set aside just in case'
      ..acquired = dateValue(date(1989, 1, 1), 500000.0)));

  get johnnyCollegeFund => (asset()
    ..assetType = AssetType.COLLEGE_SAVINGS
    ..bSItem = (bSItem()
      ..descr = 'One year of state school'
      ..acquired = dateValue(date(2010, 1, 1), 13000.0)));

  get john401K => (asset()
    ..assetType = AssetType.RETIREMENT_SAVINGS
    ..bSItem = (bSItem()
      ..descr = "401K savings plan in John's account"
      ..acquired = dateValue(date(2010, 1, 1), 77000.0)));

  get all => {
    'cottage': cottage,
    'fiveFourAndADoor': fiveFourAndADoor,
    'vwFox': vwFox,
    'caymanPorsche': caymanPorsche,
    'farmLand': farmLand,
    'term500K': term500K,
    'rainyDayFund': rainyDayFund,
    'johnnyCollegeFund': johnnyCollegeFund,
    'john401K': john401K,
  };
}

var _assets = new _Assets();

class _Liabilities {
  get primaryMortgage => (liability()
    ..liabilityType = LiabilityType.MORTGAGE
    ..bSItem = (bSItem()
      ..descr = 'Primary mortgage'
      ..acquired = dateValue(date(2000, 1, 1), 190000.0)));

  get dreamCarLoan => (liability()
    ..liabilityType = LiabilityType.AUTO_LOAN
    ..bSItem = (bSItem()
      ..descr = "Dream car loan"
      ..acquired = dateValue(date(2000, 1, 1), 70000.0)));

  get collegeEducationPurchase => (liability()
    ..liabilityType = LiabilityType.OTHER
    ..bSItem = (bSItem()
      ..descr = "A college education - usually modeled liability flows"
      ..acquired = dateValue(date(2000, 1, 1), 100000.0)));

  get all => {
    'primaryMortgage': primaryMortgage,
    'dreamCarLoan': dreamCarLoan,
    'collegeEducationPurchase': collegeEducationPurchase
  };
}

var _liabilities = new _Liabilities();

class _Holdings {
  get ibmDrip => (new Holding(HoldingType.STOCK, dv(date(2000, 1, 1), 50.0),
      dv(date(2002, 1, 1), 50.0), 50.0 * 45.0));

  get msftQdrip => (new Holding(HoldingType.STOCK, dv(date(2000, 1, 1), 50.0),
      dv(date(2002, 1, 1), 50.0), 50.0 * 45.0));

  get ibm => (new Holding(HoldingType.STOCK, dv(date(2000, 1, 1), 50.0),
      dv(date(2002, 1, 1), 50.0), 50.0 * 45.0));

  get msft => (new Holding(HoldingType.STOCK, dv(date(2000, 1, 1), 50.0),
      dv(date(2002, 1, 1), 50.0), 50.0 * 45.0));

  get nodiv => (new Holding(HoldingType.STOCK, dv(date(2000, 1, 1), 50.0),
      dv(date(2002, 1, 1), 50.0), 50.0 * 45.0));

  get all => {
    'ibmDrip': ibmDrip,
    'ibm': ibm,
    'msftQdrip': msftQdrip,
    'msft': msft,
    'nodiv': nodiv,
  };
}

final _holdings = new _Holdings();
final _sampleAccounts = {
  'college junior': (new PortfolioAccount(AccountType.COLLEGE_IRS529,
      'College Fund', 'johnDoe', _holdings.all, (new Holding(HoldingType.BLEND,
          dateValue(date(2000, 1, 1), 15000.0),
          dateValue(date(2000, 1, 1), 1.0), 10050.0)))),
  'etrade': (new PortfolioAccount(AccountType.INVESTMENT,
      'Basic holding account', 'johnDoe', _holdings.all, (new Holding(
          HoldingType.STOCK, dateValue(date(2000, 1, 1), 1000.0),
          dateValue(date(2000, 1, 1), 1.0), 950.0))))
};

class _BalanceSheets {
  get typical => new BalanceSheet(date(2014, 1, 1), {
    'fiveFourAndADoor': _assets.fiveFourAndADoor,
    'caymanPorsche': _assets.caymanPorsche,
  }, {
    'primaryMortgage': _liabilities.primaryMortgage,
    'dreamCarLoan': _liabilities.dreamCarLoan,
    'collegeEducationPurchase': _liabilities.collegeEducationPurchase,
  }, _sampleAccounts);

  get wealthy => new BalanceSheet(
      date(2014, 1, 1), _assets.all, _liabilities.all, _sampleAccounts);

  get all => {'typical': typical, 'wealthy': wealthy,};
}

var _balanceSheets = new _BalanceSheets();

// end <part balance_sheets>
