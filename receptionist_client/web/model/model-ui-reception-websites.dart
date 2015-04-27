part of model;

class UIReceptionWebsites extends UIModel {
  final Keyboard   _keyboard = new Keyboard();
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionWebsites(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _list;
  @override HtmlElement get _focusElement    => _list;
  @override SpanElement get _header          => _root.querySelector('h4 > span');
  @override SpanElement get _headerExtra     => _root.querySelector('h4 > span + span');
  @override DivElement  get _help            => null;
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
   * Add [items] to the reception websites list.
   */
  set websites(List<String> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((String item) {
      list.add(new LIElement()..text = item);
    });

    _list.children = list;
  }
}
