part of plus.portfolio;

/// A map of holdings with a particular asOf date
class Portfolio {
  Portfolio(this._asOf, this._holdings);

  Portfolio._default();

  Date get asOf => _asOf;
  Map<String, double> get holdings => _holdings;
  // custom <class Portfolio>

  Portfolio.empty(this._asOf);

  PortfolioHistory createPortfolioHistory(TradeJournal journal) =>
      new PortfolioHistory(this, journal);

  toString([bool includeFlat = true]) {
    var details = ['AsOf($_asOf)'];
    _holdings.keys.toList()
        ..sort()
        ..forEach((k) {
          double value = _holdings[k];
          if (includeFlat || value.abs() > 0.001) {
            details.add('\t$k ${commifyNum(value)}');
          }
        });
    return details.join('\n');
  }

  Portfolio copy() => new Portfolio(_asOf, new Map.from(_holdings));

  double holdingOf(String symbol) {
    var result = _holdings[symbol];
    return result == null ? 0.0 : result;
  }

  updateHolding(String symbol, double value) => _holdings[symbol] = value;

  addToHolding(String symbol, double additional) {
    _holdings.putIfAbsent(symbol, () => 0.0);
    _holdings[symbol] += additional;
  }

  // end <class Portfolio>

  Map toJson() => {
    "asOf": ebisu_utils.toJson(asOf),
    "holdings": ebisu_utils.toJson(holdings),
  };

  static Portfolio fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Portfolio._default().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _asOf = Date.fromJson(jsonMap["asOf"]);
    // holdings is Map<String,double>
    _holdings =
        ebisu_utils.constructMapFromJsonData(jsonMap["holdings"], (value) => value);
  }
  Date _asOf;
  Map<String, double> _holdings = {};
}

/// Create a Portfolio sans new, for more declarative construction
Portfolio portfolio([Date _asOf, Map<String, double> _holdings]) =>
    new Portfolio(_asOf, _holdings);

class PortfolioHistory {
  PortfolioHistory._default();

  Portfolio get portfolioSource => _portfolioSource;
  TradeJournal get tradeJournal => _tradeJournal;
  DateRange get dateRange => _dateRange;
  Map<String, TimeSeries> get holdingHistories => _holdingHistories;
  // custom <class PortfolioHistory>

  PortfolioHistory(this._portfolioSource, [TradeJournal journal]) {
    _dateRange = oneDayRange(_portfolioSource.asOf);
    addTrades(journal);
  }

  PortfolioHistory.fromAllTrades(TradeJournal journal)
      : _portfolioSource = new Portfolio.empty(
          journal.dateRange.start.priorDay),
        _dateRange = oneDayRange(journal.dateRange.start.priorDay),
        _tradeJournal = new TradeJournal.empty() {
    addTrades(journal);
  }

  addTrades(TradeJournal journal) {
    assert(_dateRange == null || !overlap(_dateRange, journal.dateRange));
    _tradeJournal.addTrades(journal.trades);
    _updateHoldings(journal);
  }

  Portfolio portfolioAsOf(Date asOf, {bool includeZeros: true}) {
    var holdings = {};
    _holdingHistories.forEach((k, ts) {
      DateValue dv = ts.firstOnOrBefore(asOf);
      double qty = dv == null ? 0.0 : dv.value;
      bool isZero = qty.abs() < 0.001;
      if (includeZeros || !isZero) {
        holdings[k] = qty;
      }
    });
    return new Portfolio(asOf, holdings);
  }

  _updateHoldings(TradeJournal journal) {
    bool arePriorTrades = journal.dateRange.isStrictlyBefore(_dateRange);
    var additions =
        arePriorTrades ? _walkTradesBackward(journal) : _walkTradesForward(journal);
    additions.forEach((k, v) {
      _holdingHistories[k] = splice(
          _holdingHistories.putIfAbsent(k, () => new TimeSeries([])),
          timeSeries(v));
    });
  }

  Map<String, TimeSeries> _walkTradesForward(journal) {
    Map result = {};

    for (var trade in journal.trades) {
      var symbol = trade.symbol;
      if (!result.containsKey(symbol)) {
        double lastValue = _portfolioSource.holdingOf(symbol);
        result[symbol] =
            [dateValue(trade.date, lastValue + trade.signedQuantity)];
      } else {
        var tsData = result[symbol];
        var last = tsData.last;
        if (last.date == trade.date) {
          last.value += trade.signedQuantity;
        } else {
          tsData.add(dateValue(trade.date, last.value + trade.signedQuantity));
        }
      }
    }
    return result;
  }

  Map<String, TimeSeries> _walkTradesBackward(journal) {

    // Track latest holdings per symbol
    var latestHoldings = valueApply(
        _portfolioSource.holdings,
        (v) => dateValue(_portfolioSource.asOf, v));

    ////////////////////////////////////////////////////////////////////////////
    // Timeline of trades up to some day (P) where portfolio quantity is known.
    //
    // ...T1..T2...T3 T4 T5....P...
    // 123  45  679        9012 3   day
    //    ^   ^          ^
    //    |   |          |
    //
    // The idea is to walk back over the trades and infer what the position was
    // along the way, given we know what it was at time of P. So, iterate over
    // trades and if it's trade.date is different than that known by
    // latestHoldings you know that that trade is the last trade on a day that
    // provided the position known at time of P -- so record the latest
    // portfolio amount calculated for that day. Remember, the position stored
    // for any given day is the position at the end of the day assuming all
    // trades have been processed.
    //
    // After processing all trades, put one more entry in the history list to
    // account for the last trade processed and then reverse the list back to
    // forward order.
    ////////////////////////////////////////////////////////////////////////////
    Map result = {};

    for (var trade in journal.trades.reversed) {
      var symbol = trade.symbol;
      var qtyDelta = trade.signedQuantity;
      var tradeDate = trade.date;
      var tsData = result.putIfAbsent(symbol, () => []);
      var latest =
          latestHoldings.putIfAbsent(symbol, () => dateValue(tradeDate, 0.0));

      if (trade.date < latest.date) {
        tsData.add(dateValue(tradeDate, latest.value));
      }

      latest.value += -qtyDelta;
      latest.date = tradeDate;
    }

    latestHoldings.forEach((k, dv) {
      var tsData = result[k];
      tsData.add(dateValue(tsData.last.date.priorDay, dv.value));
    });

    result = valueApply(result, (v) => v.reversed.toList());
    return result;
  }

  toString() {
    var orderedKeys = _holdingHistories.keys.toList()..sort();
    var result = [];
    orderedKeys.forEach((k) {
      var ts = _holdingHistories[k];
      result.add('$k\n\t');
      ts.data.forEach(
          (dv) => result.add('\t${dv.date}, ${commifyNum(dv.value)}'));
    });
    return result.join('\n');
  }

  // end <class PortfolioHistory>

  Map toJson() => {
    "portfolioSource": ebisu_utils.toJson(portfolioSource),
    "tradeJournal": ebisu_utils.toJson(tradeJournal),
    "dateRange": ebisu_utils.toJson(dateRange),
    "holdingHistories": ebisu_utils.toJson(holdingHistories),
  };

  static PortfolioHistory fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new PortfolioHistory._default().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    _portfolioSource = Portfolio.fromJson(jsonMap["portfolioSource"]);
    _tradeJournal = TradeJournal.fromJson(jsonMap["tradeJournal"]);
    _dateRange = DateRange.fromJson(jsonMap["dateRange"]);
    // holdingHistories is Map<String,TimeSeries>
    _holdingHistories = ebisu_utils.constructMapFromJsonData(
        jsonMap["holdingHistories"],
        (value) => TimeSeries.fromJson(value));
  }
  Portfolio _portfolioSource;
  TradeJournal _tradeJournal = new TradeJournal.empty();
  DateRange _dateRange;
  Map<String, TimeSeries> _holdingHistories = {};
}


// custom <part portfolio>
// end <part portfolio>

