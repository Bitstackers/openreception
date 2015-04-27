part of model;

class UIReceptionVATNumbers extends UIModel {
  final Keyboard   _keyboard = new Keyboard();
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionVATNumbers(DivElement this._myRoot) {
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
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings =
        {'Shift+Tab': _handleShiftTab,
         'Tab'      : _handleTab};

    _hotKeys.registerKeysPreventDefault(_keyboard, bindings);
  }

  /**
   * Add [items] to the reception VAT number list.
   */
  set VATnumbers(List<String> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((String item) {
      list.add(new LIElement()..text = item);
    });

    _list.children = list;
  }
}
