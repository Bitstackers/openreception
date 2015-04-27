part of model;

/**
 * TODO (TL): Comment
 */
class UIGlobalCallQueue extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIGlobalCallQueue(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _list;
  @override HtmlElement get _focusElement    => _list;
  @override HtmlElement get _lastTabElement  => _list;
  @override HtmlElement get _root            => _myRoot;

  OListElement get _list => _root.querySelector('.generic-widget-list');

  /**
   * Remove all entries from the list and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _list.children.clear();
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _list.focus());
  }

  /**
   * Add [items] to the calls list.
   */
  set calls(List<String> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((String item) {
      list.add(new LIElement()..text = item);
    });

    _list.children = list;
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }
}
