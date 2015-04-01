part of model;

class UIContactCalendar extends UIModel {
  final DivElement _myRoot;

  UIContactCalendar(DivElement this._myRoot) {
    _focusElement = _entryList;
  }

  @override HtmlElement get _root => _myRoot;

  UListElement get _entryList => _root.querySelector('ul');

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _myRoot.onClick;
}
