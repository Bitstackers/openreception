part of controller;

class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  HotKeys._internal() {
    _initialize();
  }

  Bus<KeyboardEvent> _altA     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altB     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altE     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altH     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altQ     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altW     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _shiftTab = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _tab      = new Bus<KeyboardEvent>();
  Keyboard           _keyDown  = new Keyboard();

  Stream<KeyboardEvent> get onAltA     => _altA.stream;
  Stream<KeyboardEvent> get onAltB     => _altB.stream;
  Stream<KeyboardEvent> get onAltE     => _altE.stream;
  Stream<KeyboardEvent> get onAltH     => _altH.stream;
  Stream<KeyboardEvent> get onAltQ     => _altQ.stream;
  Stream<KeyboardEvent> get onAltW     => _altW.stream;
  Stream<KeyboardEvent> get onShiftTab => _shiftTab.stream;
  Stream<KeyboardEvent> get onTab      => _tab.stream;

  /**
   *
   */
  void _initialize() {
    window.document.onKeyDown.listen(_keyDown.press);

    final Map<String, EventListener> preventDefaultBindings =
      {'Alt+a': _altA.fire,
       'Alt+b': _altB.fire,
       'Alt+e': _altE.fire,
       'Alt+h': _altH.fire,
       'Alt+q': _altQ.fire,
       'Alt+w': _altW.fire};

    final Map<String, EventListener> bindings =
        {'Tab'      : _tab.fire,
         'Shift+Tab': _shiftTab.fire};

    preventDefaultBindings.forEach((key, callback) {
      _keyDown.register(key, (Event event) {
        event.preventDefault();
        callback(event);
      });
    });

    bindings.forEach((key, callback) {
      _keyDown.register(key, callback);
    });
  }
}
