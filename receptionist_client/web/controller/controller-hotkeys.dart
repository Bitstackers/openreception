part of controller;

/**
 *
 */
class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  /**
   * Internal constructor.
   */
  HotKeys._internal() {
    _initialize();
  }

  final Keyboard _keyDown = new Keyboard();

  final Bus<KeyboardEvent> _alt1     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _alt2     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _alt3     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _alt4     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altA     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altB     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altE     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altH     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altI     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altK     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altQ     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altS     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altT     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altV     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altW     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _ctrlD    = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _ctrlE    = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _ctrlN    = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _ctrlS    = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _down     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _enter    = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _esc      = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _f1       = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _shiftTab = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _star     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _tab      = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _up       = new Bus<KeyboardEvent>();

  Stream<KeyboardEvent> get onAlt1     => _alt1.stream;
  Stream<KeyboardEvent> get onAlt2     => _alt2.stream;
  Stream<KeyboardEvent> get onAlt3     => _alt3.stream;
  Stream<KeyboardEvent> get onAlt4     => _alt4.stream;
  Stream<KeyboardEvent> get onAltA     => _altA.stream;
  Stream<KeyboardEvent> get onAltB     => _altB.stream;
  Stream<KeyboardEvent> get onAltE     => _altE.stream;
  Stream<KeyboardEvent> get onAltH     => _altH.stream;
  Stream<KeyboardEvent> get onAltI     => _altI.stream;
  Stream<KeyboardEvent> get onAltK     => _altK.stream;
  Stream<KeyboardEvent> get onAltQ     => _altQ.stream;
  Stream<KeyboardEvent> get onAltS     => _altS.stream;
  Stream<KeyboardEvent> get onAltT     => _altT.stream;
  Stream<KeyboardEvent> get onAltV     => _altV.stream;
  Stream<KeyboardEvent> get onAltW     => _altW.stream;
  Stream<KeyboardEvent> get onCtrlD    => _ctrlD.stream;
  Stream<KeyboardEvent> get onCtrlE    => _ctrlE.stream;
  Stream<KeyboardEvent> get onCtrlN    => _ctrlN.stream;
  Stream<KeyboardEvent> get onCtrlS    => _ctrlS.stream;
  Stream<KeyboardEvent> get onDown     => _down.stream;
  Stream<KeyboardEvent> get onEnter    => _enter.stream;
  Stream<KeyboardEvent> get onEsc      => _esc.stream;
  Stream<KeyboardEvent> get onF1       => _f1.stream;
  Stream<KeyboardEvent> get onShiftTab => _shiftTab.stream;
  Stream<KeyboardEvent> get onStar     => _star.stream;
  Stream<KeyboardEvent> get onTab      => _tab.stream;
  Stream<KeyboardEvent> get onUp       => _up.stream;

  void _initialize() {
    window.document.onKeyDown.listen(_keyDown.press);

    final Map<String, EventListener> preventDefaultBindings =
      {[Key.NumMult]: _star.fire,
       'Alt+1'      : _alt1.fire,
       'Alt+2'      : _alt2.fire,
       'Alt+3'      : _alt3.fire,
       'Alt+4'      : _alt4.fire,
       'Alt+a'      : _altA.fire,
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
       'Ctrl+d'     : _ctrlD.fire,
       'Ctrl+e'     : _ctrlE.fire,
       'Ctrl+n'     : _ctrlN.fire,
       'Ctrl+s'     : _ctrlS.fire,
       'Esc'        : _esc.fire,
       'F1'         : _f1.fire};

    registerKeysPreventDefault(_keyDown, preventDefaultBindings);

    final Map<String, EventListener> bindings =
        {'down'     : _down.fire,
         'Enter'    : _enter.fire,
         'Shift+Tab': _shiftTab.fire,
         'Tab'      : _tab.fire,
         'up'       : _up.fire};

    registerKeys(_keyDown, bindings);
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
