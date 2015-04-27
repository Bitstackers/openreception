part of model;

/**
 * TODO (TL): Comment
 */
class UIReceptionTelephoneNumbers extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionTelephoneNumbers(DivElement this._myRoot) {
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
   * Add [items] to the telephone number list.
   */
  set telephoneNumbers(List<TelNum> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((TelNum item) {
      final SpanElement spanLabel  = new SpanElement();
      final SpanElement spanNumber = new SpanElement();

      spanNumber.classes.toggle('secret', item.secret);
      spanNumber.classes.add('number');
      spanNumber.text = item.number;

      spanLabel.classes.add('label');
      spanLabel.text = item.label;


      list.add(new LIElement()
                ..children.addAll([spanNumber, spanLabel])
                ..dataset['id'] = item.id.toString()
                ..dataset['object'] = JSON.encode(item));
    });

    _list.children = list;
  }
}
