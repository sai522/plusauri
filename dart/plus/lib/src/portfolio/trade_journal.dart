part of plus.portfolio;

class Trade implements Comparable<Trade> {
  const Trade(
      this.date, this.symbol, this.tradeType, this.quantity, this.price);

  bool operator ==(Trade other) => identical(this, other) ||
      date == other.date &&
          symbol == other.symbol &&
          tradeType == other.tradeType &&
          quantity == other.quantity &&
          price == other.price;

  int get hashCode => hashObjects([date, symbol, tradeType, quantity, price]);

  int compareTo(Trade other) {
    int result = 0;
    ((result = date.compareTo(other.date)) == 0) &&
        ((result = symbol.compareTo(other.symbol)) == 0) &&
        ((result = tradeType.compareTo(other.tradeType)) == 0) &&
        ((result = quantity.compareTo(other.quantity)) == 0) &&
        ((result = price.compareTo(other.price)) == 0);
    return result;
  }

  copy() => new Trade._copy(this);
  final Date date;
  final String symbol;
  final TradeType tradeType;
  final double quantity;
  final double price;
  // custom <class Trade>

  get signedQuantity => tradeType == BUY ? quantity : -quantity;

  get marketValue => quantity * price;

  toString() => '($_symbolTxt$_buyOrSellTxt $quantity@$price $date)';

  get _symbolTxt => symbol == null ? '' : '$symbol: ';
  get _buyOrSellTxt => tradeType == BUY ? 'B' : 'S';

  // end <class Trade>

  Map toJson() => {
    "date": ebisu_utils.toJson(date),
    "symbol": ebisu_utils.toJson(symbol),
    "tradeType": ebisu_utils.toJson(tradeType),
    "quantity": ebisu_utils.toJson(quantity),
    "price": ebisu_utils.toJson(price),
  };

  static Trade fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Trade._fromJsonMapImpl(json);
  }

  Trade._fromJsonMapImpl(Map jsonMap)
      : date = Date.fromJson(jsonMap["date"]),
        symbol = jsonMap["symbol"],
        tradeType = TradeType.fromJson(jsonMap["tradeType"]),
        quantity = jsonMap["quantity"],
        price = jsonMap["price"];

  Trade._copy(Trade other)
      : date = other.date,
        symbol = other.symbol,
        tradeType = other.tradeType == null ? null : other.tradeType.copy(),
        quantity = other.quantity,
        price = other.price;
}

class TradeBuilder {
  TradeBuilder();

  Date date;
  String symbol;
  TradeType tradeType;
  double quantity;
  double price;
  // custom <class TradeBuilder>
  // end <class TradeBuilder>
  Trade buildInstance() => new Trade(date, symbol, tradeType, quantity, price);

  factory TradeBuilder.copyFrom(Trade _) =>
      new TradeBuilder._copyImpl(_.copy());

  TradeBuilder._copyImpl(Trade _)
      : date = _.date,
        symbol = _.symbol,
        tradeType = _.tradeType,
        quantity = _.quantity,
        price = _.price;
}

/// Create a TradeBuilder sans new, for more declarative construction
TradeBuilder tradeBuilder() => new TradeBuilder();

class TradeJournal {
  TradeJournal._default();

  bool operator ==(TradeJournal other) => identical(this, other) ||
      const ListEquality().equals(_trades, other._trades) &&
          _dateRange == other._dateRange;

  int get hashCode =>
      hash2(const ListEquality<Trade>().hash(_trades), _dateRange);

  copy() => new TradeJournal._default()
    .._trades = _trades == null
        ? null
        : (new List.from(_trades.map((e) => e == null ? null : e.copy())))
    .._dateRange = _dateRange == null ? null : _dateRange.copy();

  List<Trade> get trades => _trades;
  DateRange get dateRange => _dateRange;
  // custom <class TradeJournal>

  TradeJournal.empty() : _trades = [];

  TradeJournal(Iterable<Trade> trades) : _trades = [] {
    addTrades(trades);
  }

  TradeJournal.fromSortedList(Iterable<Trade> trades)
      : _trades = new List.from(trades);

  toString() => _trades.map((t) => t.toString()).join('\n');

  get buys => _trades.where((t) => t.tradeType == BUY);
  get sells => _trades.where((t) => t.tradeType == SELL);

  Iterable<Trade> after(Date date) => _trades.where((t) => t.date >= date);

  void addTrades(Iterable<Trade> trades) {
    var additional = new List<Trade>.from(trades)..sort();
    _trades = merge(_trades, additional);
    if (_trades.length > 0) {
      _dateRange = new DateRange(_trades.first.date, _trades.last.date.nextDay);
    }
  }

  void addSequentialTrade(Trade trade) {
    assert(_trades.length == 0 || _trades.last.date <= trade.date);
    _trades.add(trade);
  }

  // end <class TradeJournal>

  Map toJson() => {
    "trades": ebisu_utils.toJson(trades),
    "dateRange": ebisu_utils.toJson(dateRange),
  };

  static TradeJournal fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new TradeJournal._default().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    // trades is List<Trade>
    _trades = ebisu_utils.constructListFromJsonData(
        jsonMap["trades"], (data) => Trade.fromJson(data));
    _dateRange = DateRange.fromJson(jsonMap["dateRange"]);
  }
  List<Trade> _trades;
  DateRange _dateRange;
}

/// Encapsulates "accounts" of trade journals in a map indexed by account name
class TradeAccountCollection {
  TradeAccountCollection(this.tradeJournalMap);

  TradeAccountCollection._default();

  Map<String, TradeJournal> tradeJournalMap = {};
  // custom <class TradeAccountCollection>
  // end <class TradeAccountCollection>

  Map toJson() => {"tradeJournalMap": ebisu_utils.toJson(tradeJournalMap),};

  static TradeAccountCollection fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new TradeAccountCollection._default().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    // tradeJournalMap is Map<String,TradeJournal>
    tradeJournalMap = ebisu_utils.constructMapFromJsonData(
        jsonMap["tradeJournalMap"], (value) => TradeJournal.fromJson(value));
  }
}

class CostBasisEntry {
  const CostBasisEntry(this.sell, this.offsettingBuys, this.cost,
      this.shortTermGain, this.longTermGain, this.lotCloseMethod);

  copy() => new CostBasisEntry._copy(this);
  final Trade sell;
  final List<Trade> offsettingBuys;
  final double cost;
  final double shortTermGain;
  final double longTermGain;
  final LotCloseMethod lotCloseMethod;
  // custom <class CostBasisEntry>

  toString() => '''
CostBasisEntry
\tsell => $sell
\tbuys => $offsettingBuys
\tcost => $cost
\tshortTermGain => $shortTermGain
\tlongTermGain => $longTermGain
''';

  // end <class CostBasisEntry>
  CostBasisEntry._copy(CostBasisEntry other)
      : sell = other.sell == null ? null : other.sell.copy(),
        offsettingBuys = other.offsettingBuys == null
            ? null
            : (new List.from(
                other.offsettingBuys.map((e) => e == null ? null : e.copy()))),
        cost = other.cost,
        shortTermGain = other.shortTermGain,
        longTermGain = other.longTermGain,
        lotCloseMethod = other.lotCloseMethod == null
            ? null
            : other.lotCloseMethod.copy();
}

class CostBasisEntryBuilder {
  CostBasisEntryBuilder();

  Trade sell;
  List<Trade> offsettingBuys;
  double cost;
  double shortTermGain;
  double longTermGain;
  LotCloseMethod lotCloseMethod;
  // custom <class CostBasisEntryBuilder>
  // end <class CostBasisEntryBuilder>
  CostBasisEntry buildInstance() => new CostBasisEntry(
      sell, offsettingBuys, cost, shortTermGain, longTermGain, lotCloseMethod);

  factory CostBasisEntryBuilder.copyFrom(CostBasisEntry _) =>
      new CostBasisEntryBuilder._copyImpl(_.copy());

  CostBasisEntryBuilder._copyImpl(CostBasisEntry _)
      : sell = _.sell,
        offsettingBuys = _.offsettingBuys,
        cost = _.cost,
        shortTermGain = _.shortTermGain,
        longTermGain = _.longTermGain,
        lotCloseMethod = _.lotCloseMethod;
}

/// Create a CostBasisEntryBuilder sans new, for more declarative construction
CostBasisEntryBuilder costBasisEntryBuilder() => new CostBasisEntryBuilder();

abstract class LotCloser {
  // custom <class LotCloser>

  LotCloseMethod get lotCloseMethod;

  closeLots(TradeTaxAssessor tradeTaxAssessor, DateRange onRange) {
    var openLots = new List.from(tradeTaxAssessor.openLots);
    var closedLots = [];

    while (openLots.length > 0) {
      final nextSellIndex = _indexOfNextSale(openLots);

      if (Logger.root.level <= Level.FINER) _logger
          .finer('OpenLots => $openLots => $nextSellIndex');

      assert(nextSellIndex != 0);
      if (nextSellIndex > 0) {
        final buys = openLots.sublist(0, nextSellIndex);
        final sale = openLots[nextSellIndex];
        final matchResult = closeLot(buys, sale);

        if (Logger.root.level <= Level.FINER) _logger.finer(
            'MR => $matchResult => ${matchResult.createCostBasisEntry()}');

        tradeTaxAssessor._addCostBasisEntry(matchResult.createCostBasisEntry());

        openLots = (matchResult.residualTrade != null
            ? [matchResult.residualTrade]
            : [])
          ..addAll(matchResult.remainingBuys)
          ..addAll(openLots.sublist(nextSellIndex + 1));
        closedLots.addAll(matchResult.matchedBuys);
      } else {
        break;
      }
    }

    tradeTaxAssessor._closedLots.addAll(closedLots);
    tradeTaxAssessor._openLots = openLots;
    if (Logger.root.level <= Level.FINER) _logger
        .finer('Remainging lots ${openLots.length}');
  }

  MatchResult closeLot(List<Trade> openBuys, Trade sale);

  // end <class LotCloser>
}

class FIFOLotCloser extends LotCloser {
  // custom <class FIFOLotCloser>

  LotCloseMethod get lotCloseMethod => LotCloseMethod.FIFO;

  MatchResult closeLot(List<Trade> buys, Trade sale) =>
      new MatchResult.fromBuys(buys, sale, lotCloseMethod);

  // end <class FIFOLotCloser>
}

class LIFOLotCloser extends LotCloser {
  // custom <class LIFOLotCloser>

  LotCloseMethod get lotCloseMethod => LotCloseMethod.LIFO;

  MatchResult closeLot(List<Trade> buys, Trade sale) =>
      new MatchResult.fromBuys(buys.reversed, sale, lotCloseMethod);

  // end <class LIFOLotCloser>
}

class HIFOLotCloser extends LotCloser {
  // custom <class HIFOLotCloser>

  LotCloseMethod get lotCloseMethod => LotCloseMethod.HIFO;

  MatchResult closeLot(List<Trade> buys, Trade sale) {
    buys.sort((Trade a, Trade b) => a.price.compareTo(b.price));
    return new MatchResult.fromBuys(buys.reversed, sale, lotCloseMethod);
  }

  // end <class HIFOLotCloser>
}

class LowCostLotCloser extends LotCloser {
  // custom <class LowCostLotCloser>

  LotCloseMethod get lotCloseMethod => LotCloseMethod.LOW_COST;

  MatchResult closeLot(List<Trade> buys, Trade sale) {
    buys.sort((Trade a, Trade b) => b.price.compareTo(a.price));
    return new MatchResult.fromBuys(buys.reversed, sale, lotCloseMethod);
  }

  // end <class LowCostLotCloser>
}

/// Calculates taxes on trade journals
class TradeTaxAssessor {
  TradeTaxAssessor(this._tradeJournal);

  TradeJournal get tradeJournal => _tradeJournal;
  List<Trade> get closedLots => _closedLots;
  List<Trade> get openLots => _openLots;
  List<CostBasisEntry> get costBasisEntries => _costBasisEntries;
  double get shortTermGain => _shortTermGain;
  double get longTermGain => _longTermGain;
  // custom <class TradeTaxAssessor>

  closeLots(LotCloser lotCloser, DateRange onRange) {
    _checkForNewLots();
    lotCloser.closeLots(this, onRange);
  }

  _checkForNewLots() => _openLots.addAll(_tradeJournal
      .after(_openLots.length > 0 ? _openLots.last.date : EarliestDate)
      .map((trade) => trade.copy()));

  _addCostBasisEntry(CostBasisEntry cbe) {
    _costBasisEntries.add(cbe);
    _shortTermGain += cbe.shortTermGain;
    _longTermGain += cbe.longTermGain;
  }

  // end <class TradeTaxAssessor>
  TradeJournal _tradeJournal;
  List<Trade> _closedLots = [];
  List<Trade> _openLots = [];
  List<CostBasisEntry> _costBasisEntries = [];
  double _shortTermGain = 0.0;
  double _longTermGain = 0.0;
}

class MatchResult {
  const MatchResult(this.sell, this.matchedBuys, this.residualTrade,
      this.remainingBuys, this.lotCloseMethod);

  final Trade sell;
  final List<Trade> matchedBuys;
  final Trade residualTrade;
  final List<Trade> remainingBuys;
  final LotCloseMethod lotCloseMethod;
  // custom <class MatchResult>

  factory MatchResult.fromBuys(
      Iterable<Trade> allBuys, Trade sell, LotCloseMethod lotCloseMethod) {
    var toBeSold = sell.quantity;
    List<Trade> matchedBuys = [];
    Trade residualTrade;
    int count = 0;

    for (Trade buy in allBuys) {
      final buyQty = buy.quantity;
      count++;

      if (toBeSold > buyQty) {
        matchedBuys.add(buy);
        toBeSold -= buyQty;
      } else if (toBeSold == buyQty) {
        matchedBuys.add(buy);
        break;
      } else {
        // Overmatched the units sold
        matchedBuys.add((new TradeBuilder.copyFrom(buy)..quantity = toBeSold)
            .buildInstance());
        residualTrade = (new TradeBuilder.copyFrom(buy)
          ..quantity = buyQty - toBeSold).buildInstance();
        break;
      }
    }

    return new MatchResult(sell, matchedBuys, residualTrade,
        allBuys.skip(count).toList(), lotCloseMethod);
  }

  CostBasisEntry createCostBasisEntry() {
    final salePrice = sell.price;
    double cost = 0.0,
        shortTermGain = 0.0,
        longTermGain = 0.0;
    matchedBuys.forEach((buy) {
      final delta = buy.quantity * (salePrice - buy.price);
      cost += buy.marketValue;
      if ((sell.date - buy.date).inDays >= 365) {
        longTermGain += delta;
      } else {
        shortTermGain += delta;
      }
    });

    assert((longTermGain + shortTermGain - (sell.marketValue - cost)).abs() <
        0.0001);
    return new CostBasisEntry(
        sell, matchedBuys, cost, shortTermGain, longTermGain, lotCloseMethod);
  }

  toString() => '''
\tmethod => $lotCloseMethod
\tsell => $sell
\tremainingBuys => $remainingBuys
\tmatchedBuys => $matchedBuys$_residualTradeTxt
''';

  get _residualTradeTxt => residualTrade == null ? '' : '\n\t$residualTrade';

  // end <class MatchResult>
}

class AvgCostAccumulator {
  AvgCostAccumulator._default();

  copy() => new AvgCostAccumulator._default()
    ..totalCost = totalCost
    ..totalValue = totalValue
    ..totalQty = totalQty;

  double totalCost;
  double totalValue;
  double totalQty;
  // custom <class AvgCostAccumulator>

  AvgCostAccumulator(this.totalCost, this.totalValue, [this.totalQty]) {
    if (totalQty == null) totalQty = totalCost;
    assert(_isValid);
  }

  double markValue(double mark) => totalValue = mark;
  double get price => totalQty == 0.0 ? 0.0 : totalValue / totalQty;
  double get unitCost => totalQty == 0.0 ? 0.0 : totalCost / totalQty;

  void buy(double buyValue) {
    double price = (totalQty == 0.0) ? 1.0 : this.price;
    assert(price != 0.0);

    final buyQty = buyValue / price;
    totalCost += buyValue;
    totalQty += buyQty;
    totalValue += buyValue;
  }

  double sell(double sellValue) {
    assert(price != 0.0);
    final sellQty = sellValue / price;

    double tradeBasisCost = (totalCost / totalQty) * sellQty;
    double gain = sellValue - tradeBasisCost;

    totalCost -= tradeBasisCost;
    totalQty -= sellQty;
    totalValue -= sellValue;

    return gain;
  }

  void reinvestFunds(double dividend) {
    totalValue -= dividend;
    buy(dividend);
  }

  void deductDistribution(double dividend) {
    totalValue -= dividend;
  }

  void markThenBuy(double mark, double buyValue) {
    assert(_isValid);
    if (totalValue == 0.0 && totalCost == 0.0 && totalQty == 0.0) {
      totalCost = buyValue;
      totalValue = buyValue;
      totalQty = totalCost;
    } else {
      markValue(mark);
      buy(buyValue);
    }
    assert(_isValid);
  }

  double markThenSell(double mark, double sellValue) {
    assert(_isValid);
    markValue(mark);
    final gain = sell(sellValue);
    assert(_isValid);

    if (totalValue < MinAccountBalance) {
      totalValue = 0.0;
      totalCost = 0.0;
      totalQty = 0.0;
    }

    return gain;
  }

  bool get _isValid => totalValue >= 0.0 && totalQty >= 0.0 && totalCost >= 0.0;

  toString() => '''
totalValue: $totalValue
totalQty: $totalQty
totalCost: $totalCost
''';

  // end <class AvgCostAccumulator>
}
// custom <part trade_journal>

tradeJournal(List<Trade> trades) => new TradeJournal(trades);

int _indexOfNextSale(Iterable<Trade> trades) {
  int result = 0;
  for (var trade in trades) {
    if (trade.tradeType != BUY) break;
    result++;
  }
  return result == trades.length ? -1 : result;
}

const double MinAccountBalance = 0.01;

// end <part trade_journal>
