part of controller;

/**
 *
 */
class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  HotKeys._internal() {
    _initialize();
  }

  Bus<KeyboardEvent> _alt1     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _alt2     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _alt3     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altA     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altB     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altE     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altH     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altI     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altK     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altQ     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altS     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altT     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _altW     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _shiftTab = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _tab      = new Bus<KeyboardEvent>();
  Keyboard           _keyDown  = new Keyboard();

  Bus<KeyboardEvent> _onCtrlBackspace     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _onCtrlAltEnter     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _onCtrlAltP     = new Bus<KeyboardEvent>();

  Bus<KeyboardEvent> _onCtrlE     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _onCtrlK     = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _onCtrlS     = new Bus<KeyboardEvent>();


  Stream<KeyboardEvent> get onAlt1     => _alt1.stream;
  Stream<KeyboardEvent> get onAlt2     => _alt2.stream;
  Stream<KeyboardEvent> get onAlt3     => _alt3.stream;
  Stream<KeyboardEvent> get onAltA     => _altA.stream;
  Stream<KeyboardEvent> get onAltB     => _altB.stream;
  Stream<KeyboardEvent> get onAltE     => _altE.stream;
  Stream<KeyboardEvent> get onAltH     => _altH.stream;
  Stream<KeyboardEvent> get onAltI     => _altI.stream;
  Stream<KeyboardEvent> get onAltK     => _altK.stream;
  Stream<KeyboardEvent> get onAltQ     => _altQ.stream;
  Stream<KeyboardEvent> get onAltS     => _altS.stream;
  Stream<KeyboardEvent> get onAltT     => _altT.stream;
  Stream<KeyboardEvent> get onAltW     => _altW.stream;
  Stream<KeyboardEvent> get onShiftTab => _shiftTab.stream;
  Stream<KeyboardEvent> get onTab      => _tab.stream;

  Stream<KeyboardEvent> get onCtrlBackspace => _onCtrlBackspace.stream;
  Stream<KeyboardEvent> get onCtrlAltEnter => _onCtrlAltEnter.stream;
  Stream<KeyboardEvent> get onCtrlAltP => _onCtrlAltP.stream;

  Stream<KeyboardEvent> get onCtrlE => _onCtrlE.stream;
  Stream<KeyboardEvent> get onCtrlK => _onCtrlK.stream;
  Stream<KeyboardEvent> get onCtrlS => _onCtrlS.stream;

  /**
   *
   */

  void _initialize() {
    window.document.onKeyDown.listen(_keyDown.press);

    final Map<String, EventListener> preventDefaultBindings =
      {'Alt+1': _alt1.fire,
       'Alt+2': _alt2.fire,
       'Alt+3': _alt3.fire,
       'Alt+a': _altA.fire,
       'Alt+b': _altB.fire,
       'Alt+e': _altE.fire,
       'Alt+h': _altH.fire,
       'Alt+i': _altI.fire,
       'Alt+k': _altK.fire,
       'Alt+q': _altQ.fire,
       'Alt+s': _altS.fire,
       'Alt+t': _altT.fire,
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
