part of controller;

/**
 * TODO (TL): Comment
 */
class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  final Keyboard _keyDown = new Keyboard();

  final Bus<KeyboardEvent> _altA = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altB = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altE = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altH = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altI = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altK = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altQ = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altS = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altT = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altV = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altW = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _f1   = new Bus<KeyboardEvent>();

  Stream<KeyboardEvent> get onAltA => _altA.stream;
  Stream<KeyboardEvent> get onAltB => _altB.stream;
  Stream<KeyboardEvent> get onAltE => _altE.stream;
  Stream<KeyboardEvent> get onAltH => _altH.stream;
  Stream<KeyboardEvent> get onAltI => _altI.stream;
  Stream<KeyboardEvent> get onAltK => _altK.stream;
  Stream<KeyboardEvent> get onAltQ => _altQ.stream;
  Stream<KeyboardEvent> get onAltS => _altS.stream;
  Stream<KeyboardEvent> get onAltT => _altT.stream;
  Stream<KeyboardEvent> get onAltV => _altV.stream;
  Stream<KeyboardEvent> get onAltW => _altW.stream;
  Stream<KeyboardEvent> get onF1   => _f1.stream;

  /**
   * Internal constructor.
   */
  HotKeys._internal() {
    window.document.onKeyDown.listen(_keyDown.press);

    final Map<String, EventListener> preventDefaultBindings =
      {'Alt+a'      : _altA.fire,
       'Alt+b'      : _altB.fire,
       'Alt+e'      : _altE.fire,
       'Alt+h'      : _altH.fire,
       'Alt+i'      : _altI.fire,
       'Alt+k'      : _altK.fire,
       'Alt+q'      : _altQ.fire,
       'Alt+s'      : _altS.fire,
       'Alt+t'      : _altT.fire,
       'Alt+v'      : _altV.fire,
       'Alt+w'      : _altW.fire,
       'F1'         : _f1.fire};

    registerKeysPreventDefault(_keyDown, preventDefaultBindings);
  }

  /**
   * Register the [keyMap] keybindings to [keyboard].
   */
  void registerKeys(Keyboard keyboard, Map<String, EventListener> keyMap) {
    keyMap.forEach((key, callback) {
      keyboard.register(key, callback);
    });
  }

  /**
   * Register the [keyMap] key bindings to [keyboard]. Prevent default on all
   * key events.
   */
  void registerKeysPreventDefault(Keyboard keyboard, Map<String, EventListener> keyMap) {
    keyMap.forEach((key, callback) {
      keyboard.register(key, (Event event) {
        event.preventDefault();
        callback(event);
      });
    });
  }
}
