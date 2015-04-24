part of model;

class UIWelcomeMessage extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIWelcomeMessage(DivElement this._myRoot);

  @override HtmlElement        get _firstTabElement => null;
  @override HtmlElement        get _focusElement    => null;
  @override SpanElement        get _header          => null;
  @override SpanElement        get _headerExtra     => null;
  @override DivElement         get _help            => null;
  @override HtmlElement        get _lastTabElement  => null;
  @override HtmlElement        get _root            => _myRoot;

  SpanElement get _greeting => _root.querySelector('.greeting');

  /**
   * Clear the welcome message widget.
   */
  void clear() {
    greeting = '';
  }

  /**
   * Set the [Reception] greeting.
   */
  set greeting (String value) => _greeting.text = value;
}
