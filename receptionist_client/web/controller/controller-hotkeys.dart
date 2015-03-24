part of controller;

class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  HotKeys._internal() {
    _initialize();
  }

  Bus<KeyboardEvent> _AltA    = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _AltB    = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _AltE    = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _AltH    = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _AltQ    = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _AltW    = new Bus<KeyboardEvent>();
  Keyboard           _keyDown = new Keyboard();

  Stream<KeyboardEvent> get onAltA => _AltA.stream;
  Stream<KeyboardEvent> get onAltB => _AltB.stream;
  Stream<KeyboardEvent> get onAltE => _AltE.stream;
  Stream<KeyboardEvent> get onAltH => _AltH.stream;
  Stream<KeyboardEvent> get onAltQ => _AltQ.stream;
  Stream<KeyboardEvent> get onAltW => _AltW.stream;

  /**
   *
   */
  void _initialize() {
    window.document.onKeyDown.listen(_keyDown.press);

    Map<String, EventListener> keyDownBindings =
      {'Alt+a'          : _AltA.fire,
       'Alt+b'          : _AltB.fire,
       'Alt+e'          : _AltE.fire,
       'Alt+h'          : _AltH.fire,
       'Alt+q'          : _AltQ.fire,
       'Alt+w'          : _AltW.fire};

    keyDownBindings.forEach((key, callback) {
      _keyDown.register(key, (Event event) {
        event.preventDefault();
        callback(event);
      });
    });
  }
}
