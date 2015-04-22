part of model;

class UIReceptionCommands extends UIModel {
  final Keyboard   _keyboard = new Keyboard();
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionCommands(DivElement this._myRoot) {
    _help.text = 'alt+h';

    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _root;
  @override HtmlElement get _focusElement    => _commandList;
  @override SpanElement get _header          => _root.querySelector('h4 > span');
  @override SpanElement get _headerExtra     => _root.querySelector('h4 > span + span');
  @override DivElement  get _help            => _root.querySelector('div.help');
  @override HtmlElement get _lastTabElement  => _root;
  @override HtmlElement get _root            => _myRoot;

  OListElement get _commandList => _root.querySelector('.generic-widget-list');

  /**
   * Remove all entries from the command list and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _commandList.children.clear();
  }

  /**
   * Add [items] to the commands list.
   */
  set commands(List<Command> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((Command item) {
      list.add(new LIElement()
                ..dataset['object'] = JSON.encode(item)
                ..text = item.command);
    });

    _commandList.children = list;
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _commandList.focus());
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
}
