part of model;

/**
 * TODO (TL): Comment
 */
class UIMessageArchiveEdit extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIMessageArchiveEdit(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement    => _body;
  @override HtmlElement get _lastTabElement  => _body;
  @override HtmlElement get _root            => _myRoot;

  DivElement get _body => _root.querySelector('.generic-widget-body');

  /**
   * Remove all data from the body and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _body.text = '';
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _body.focus());
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }
}
