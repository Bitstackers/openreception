part of model;

class UIReceptionCommands extends UIModel {
  final DivElement _myRoot;

  UIReceptionCommands(DivElement this._myRoot);

  @override HtmlElement get _firstTabElement => null;
  @override HtmlElement get _focusElement    => _commandList;
  @override HtmlElement get _lastTabElement  => null;
  @override HtmlElement get _root            => _myRoot;

  UListElement   get _commandList => _root.querySelector('ul');
  HeadingElement get _header      => _root.querySelector('h4');

  /**
   * Set the widget header.
   */
  set header(String headline) => _header.text = headline;

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _myRoot.onClick;
}
