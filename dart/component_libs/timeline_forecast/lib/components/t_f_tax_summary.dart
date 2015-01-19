library t_f_tax_summary;
import 'dart:html' hide Timeline;
import 'package:basic_input/formatting.dart';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:timeline_forecast/composite_table.dart';
import 'package:timeline_forecast/current_dollars.dart';
import 'package:timeline_forecast/timeline_model.dart';

  // custom <additional imports>
  // end <additional imports>


final _logger = new Logger("tFTaxSummary");

@CustomTag("plus-t-f-tax-summary")
class TFTaxSummary extends PolymerElement {
  HtmlElement get container => _container;
  @observable String year;

  TFTaxSummary.created() : super.created() {
    _logger.fine('TFTaxSummary created sr => $shadowRoot');
    // custom <TFTaxSummary created>
    // end <TFTaxSummary created>

  }

  @override
  void domReady() {
    super.domReady();
    _logger.fine('TFTaxSummary domReady with sr => $shadowRoot');
    // custom <TFTaxSummary domReady>
    // end <TFTaxSummary domReady>

  }

  @override
  void ready() {
    super.ready();
    _logger.fine('TFTaxSummary ready with sr => $shadowRoot');
    // custom <TFTaxSummary ready>
    // end <TFTaxSummary ready>

  }

  @override
  void attached() {
    // custom <TFTaxSummary pre-attached>
    // end <TFTaxSummary pre-attached>

    super.attached();
    _logger.fine('TFTaxSummary attached with sr => $shadowRoot');
    assert(shadowRoot != null);
    // custom <TFTaxSummary attached>
    _taxSummaryTable = $['tax-summary-table'];
    _container = $['container'];
    // end <TFTaxSummary attached>

    _isAttached = true;
    _onAttachedHandlers.forEach((handler) => handler(this));
  }

  void onAttached(void onAttachedHandler(TFTaxSummary)) {
    if(_isAttached) {
      onAttachedHandler(this);
    } else {
      _onAttachedHandlers.add(onAttachedHandler);
    }
  }

  // custom <class TFTaxSummary>

  setModel(ITaxSummaryModel model,
      CurrentDollarsToggler currentDollarsToggler,
      int year) {
    _model = model;
    _currentDollarsToggler = currentDollarsToggler;
    this.year = '$year';
    if(_compositeTable == null) {
      _initializeTable();
    }
    _displayModel(year);
  }

  _initializeTable() {
    _taxSummaryTable.createTBody();
    _compositeTable = new CompositeTable(_taxSummaryTable);
  }

  _displayModel(int year) {
    _compositeTable.clear();

    _compositeTable.addTopRow(_columnHeadersLabel)
      ..addColumns(_numColumns)
      ..cellContents(_taxBasisValueCellIndex, 'Basis (${year-1})')
      ..cellContents(_taxTaxValueCellIndex, 'Tax')
      ..cellContents(_taxEffectiveRateCellIndex, 'Effective Rate')
      ..cellContents(_taxPctCellIndex, 'Percent Total')
      ..addClass('tax-header');

    double sumBasis = 0.0;
    double sumTaxes = _model.totalTaxes;

    addRow(String label, double basis, double tax) {
      var row = _compositeTable.addTopRow(label)
        ..addColumns(_numColumns)
        ..cellContents(_taxBasisNameCellIndex, label)
        ..cellContents(_taxBasisValueCellIndex, moneyFormat(basis, false))
        ..cellContents(_taxTaxValueCellIndex, moneyFormat(tax, false))
        ..cellContents(_taxEffectiveRateCellIndex,
            basis != 0.0?
            percentFormat(tax/basis, false) : '')
        ..cellContents(_taxPctCellIndex,
            sumTaxes != 0.0?
            percentFormat(tax/sumTaxes, false) : '');

      sumBasis += basis;

      if(basis == 0.0) {
        row.addClass('no-tax');
      }
    }

    _model.visitPension((basis, tax) => addRow('Pension Income', basis, tax));
    _model.visitSocialSecurity((basis, tax) => addRow('Social Security Income', basis, tax));
    _model.visitRental((basis, tax) => addRow('Rental Income', basis, tax));
    _model.visitLabor((basis, tax) => addRow('Ordinary Income', basis, tax));
    _model.visitCapitalGain((basis, tax) => addRow('Capital Gains', basis, tax));
    _model.visitQualifiedDividends((basis, tax) => addRow('Qualified Dividends', basis, tax));
    _model.visitUnqualifiedDividends((basis, tax) => addRow('Unqualified Dividends', basis, tax));
    _model.visitCapitalGainDistributions((basis, tax) => addRow('Capital Gain Distributions', basis, tax));
    _model.visitInterest((basis, tax) => addRow('Interest', basis, tax));

    _model.visitShelteredCapitalGain((basis, tax) => addRow('Sheltered Capital Gains', basis, tax));
    _model.visitShelteredQualifiedDividends((basis, tax) => addRow('Sheltered Qualified Dividends', basis, tax));
    _model.visitShelteredUnqualifiedDividends((basis, tax) => addRow('Sheltered Unqualified Dividends', basis, tax));
    _model.visitShelteredCapitalGainDistributions((basis, tax) => addRow('Sheltered Capital Gain Distributions', basis, tax));
    _model.visitShelteredInterest((basis, tax) => addRow('Sheltered Interest', basis, tax));

    _compositeTable.addTopRow('Divider')
      ..addColumns(1)
      ..cellContents(_taxBasisNameCellIndex, '<hr>')
      ..cells[0].attributes['colspan'] = '$_numColumns';

    _compositeTable.addTopRow('Tax Bill')
      ..addColumns(_numColumns)
      ..cellContents(_taxBasisNameCellIndex, 'Tax Bill')
      ..cellContents(_taxTaxValueCellIndex, moneyFormat(sumTaxes, false))
      ..cellContents(_taxEffectiveRateCellIndex,
          sumBasis != 0.0?
          percentFormat(sumTaxes/sumBasis, false) : '')
      ..addClass('tax-bill');
  }

  get _numColumns => 5;
  get _taxBasisNameCellIndex => 0;
  get _taxBasisValueCellIndex => 1;
  get _taxTaxValueCellIndex => 2;
  get _taxEffectiveRateCellIndex => 3;
  get _taxPctCellIndex => 4;

  get _columnHeadersLabel => 'Column Headers';


  // end <class TFTaxSummary>
  HtmlElement _container;
  ITaxSummaryModel _model;
  CurrentDollarsToggler _currentDollarsToggler;
  TableElement _taxSummaryTable;
  CompositeTable _compositeTable;
  bool _isAttached = false;
  List _onAttachedHandlers = [];
}




// custom <t_f_tax_summary>
// end <t_f_tax_summary>
