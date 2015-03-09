part of controller;

class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  Keyboard _keyDown = new Keyboard();

  Bus<KeyboardEvent> _CtrlBackspace = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _CtrlE         = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _CtrlK         = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _CtrlS         = new Bus<KeyboardEvent>();

  Stream<KeyboardEvent> get onCtrlBackspace => _CtrlBackspace.stream;
  Stream<KeyboardEvent> get onCtrlE         => _CtrlE.stream;
  Stream<KeyboardEvent> get onCtrlK         => _CtrlK.stream;
  Stream<KeyboardEvent> get onCtrlS         => _CtrlS.stream;

  HotKeys._internal() {
    window.document.onKeyDown.listen(_keyDown.press);

    Map<String, EventListener> keyDownBindings =
      {'Alt+g'          : Call.hangup(Model.Call.currentCall),
       'Alt+l'          : Call.park(Model.Call.currentCall),
       'Alt+o'          : Call.transfer(Model.Call.currentCall, Model.CallList.instance.firstParkedCall),
       'Alt+p'          : Call.pickupNext,
       'Alt+u'          : Call.pickupParked(Model.CallList.instance.firstParkedCall),
       'Ctrl+Alt+Enter' : User.signalReady,
       'Ctrl+Alt+p'     : User.signalPaused,
       'Ctrl+Backspace' : _CtrlBackspace.fire,
       'Ctrl+e'         : _CtrlE.fire,
       'Ctrl+k'         : _CtrlK.fire,
       'Ctrl+s'         : _CtrlS.fire};

    keyDownBindings.forEach((key, callback) {
      _keyDown.register(key, (KeyboardEvent event) {
        event.preventDefault();
        callback(event);
      });
    });
  }
}
