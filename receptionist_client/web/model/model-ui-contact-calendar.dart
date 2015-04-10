part of model;

class UIContactCalendar extends UIModel {
  final DivElement _myRoot;

  UIContactCalendar(DivElement this._myRoot);

  @override HtmlElement get _firstTabElement => null;
  @override HtmlElement get _focusElement    => _entryList;
  @override HtmlElement get _lastTabElement  => null;
  @override HtmlElement get _root            => _myRoot;

  UListElement   get _entryList => _root.querySelector('ul');
  HeadingElement get _header    => _root.querySelector('h4');

  /**
   * Set the widget header.
   */
  set header(String headline) => _header.text = headline;

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _myRoot.onClick;
}
