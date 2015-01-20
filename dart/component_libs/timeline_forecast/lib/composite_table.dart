library timeline_forecast.composite_table;

import 'dart:html';
import 'package:quiver/iterables.dart' as quiver;
// custom <additional imports>

import 'package:core_elements/core_icon_button.dart';

// end <additional imports>

class CompositeTable {
  CompositeTable(this._table);

  // custom <class CompositeTable>

  CompositeRow addTopRow(String rowKey, [RowFactory rowFactory]) =>
      (_topRows..add(_addRow(rowKey, rowFactory))).last;

  CompositeRow addChildRow(CompositeRow parent, String rowKey,
      [RowFactory rowFactory]) {
    final child = _addRow(rowKey, rowFactory)
      .._indentLevel = parent.indentLevel + 1;
    parent.add(child);
    return child;
  }

  getRow(String key) => _rows[key];
  clear() {
    _table.children.clear();
    _rows.clear();
  }

  collapseAll() => visit(_collapseAllImpl);
  expandAll() => visit(_expandAllImpl);
  visit(VisitAction action) => _topRows.forEach((row) => row.visit(action));

  _collapseAllImpl(CompositeRow row) => row.collapse();
  _expandAllImpl(CompositeRow row) => row.expand();

  static CompositeRow _defaultRowFactory(TableRowElement row) =>
      new CompositeRow(row);

  _addRow(String rowKey, [RowFactory rowFactory]) {
    if (rowFactory == null) rowFactory = _defaultRowFactory;
    assert(_rows[rowKey] == null);
    var row = new TableRowElement();
    _table.children.add(row);
    return (_rows[rowKey] = rowFactory(row));
  }

  // end <class CompositeTable>
  List<CompositeRow> _topRows = [];
  Map<String, CompositeRow> _rows = {};
  TableElement _table;
}

class CompositeRow {
  CompositeRow(this._row);

  /// Indicates this row is collapsed (i.e. no children displayed).
  /// The row itself may also be hidden by user
  bool get isCollapsed => _isCollapsed;
  TableRowElement get row => _row;
  int get indentLevel => _indentLevel;
  CollapseVisual collapseVisual;
  // custom <class CompositeRow>

  get style => _row.style;
  get cells => _row.cells;
  addCell() => _row.children.add(new TableCellElement());

  cellContents(int i, String html) {
    _row.cells[i].innerHtml = html;
  }

  cellChildElement(int i, HtmlElement elm) => _row.cells[i].children = [elm];

  add(CompositeRow child) => _children.add(child);
  addColumns(int i) => quiver.range(i).forEach((_) => _row.addCell());
  addClass(String cls) => _row.classes.add(cls);
  removeClass(String cls) => _row.classes.remove(cls);

  hide() {
    _isHidden = true;
    _updateVisual();
  }

  show() {
    _isHidden = false;
    _updateVisual();
  }

  collapse() {
    _children.forEach((child) => child._collapseHide());
    _isCollapsed = true;
    _updateVisual();
  }

  expand() {
    _children.forEach((child) => child._collapseShow());
    _isCollapsed = false;
    _updateVisual();
  }

  toggle() => _isCollapsed ? expand() : collapse();

  visit(VisitAction action) {
    action(this);
    _children.forEach((child) => child.visit(action));
  }

  _collapseHide() {
    _isCollapseHidden = true;
    _children.forEach((child) => child._collapseHide());
    _updateVisual();
  }

  _collapseShow() {
    _isCollapseHidden = false;
    if (!_isCollapsed) {
      _children.forEach((child) => child._collapseShow());
    }
    _updateVisual();
  }

  _updateVisual() {
    if (_isHidden || _isCollapseHidden) {
      _row.style.setProperty('display', 'none');
    } else {
      _row.style.removeProperty('display');
    }
    if (collapseVisual != null) {
      collapseVisual(this, _isCollapsed);
    }
  }

  // end <class CompositeRow>
  List<CompositeRow> _children = [];
  /// Indicates user has requested row be hidden
  bool _isHidden = false;
  bool _isCollapsed = false;
  /// Indicates the row should not be displayed because it is hidden due to its parent
  /// being collapsed.
  bool _isCollapseHidden = false;
  TableRowElement _row;
  int _indentLevel = 0;
}

// custom <library composite_table>

typedef CompositeRow RowFactory(TableRowElement row);
typedef void VisitAction(CompositeRow row);
typedef void CollapseVisual(CompositeRow row, bool collapsed);

const _expandIcon = 'add-circle';
const _collapseIcon = 'remove-circle';

CoreIconButton createCollapseIcon() =>
    new Element.tag('core-icon-button')..attributes['icon'] = _collapseIcon;

CoreIconButton createExpandIcon() =>
    new Element.tag('core-icon-button')..attributes['icon'] = _expandIcon;

CoreIconButton createCurrentDollarsIcon() =>
    new Element.tag('core-icon-button')..attributes['icon'] = 'arrow-back';

CoreIconButton createFutureDollarsIcon() =>
    new Element.tag('core-icon-button')..attributes['icon'] = 'arrow-forward';

Element createLabel(String label) => new DivElement()..text = label;

DivElement createRowCollapser(String label) => new DivElement()
  ..attributes['horizontal'] = ''
  ..attributes['layout'] = ''
  ..children = [createCollapseIcon(), createLabel(label)];

attachExpandHandler(CompositeRow row) {
  row.collapseVisual = visualCollapser;
  getExpander(row).onClick.listen((me) {
    row.toggle();
    me.stopImmediatePropagation();
  });
}

getExpander(CompositeRow row) => row.cells[0].children[0].children[0];

visualCollapser(CompositeRow row, bool isCollapsed) {
  final elm = getExpander(row);
  final icon = elm.attributes['icon'];
  elm.attributes['icon'] = (_expandIcon == icon) ? _collapseIcon : _expandIcon;
}

// end <library composite_table>
