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
      {'Alt+g'          : _AltG,
       'Alt+l'          : _AltL,
       'Alt+o'          : _AltO,
       'Alt+p'          : _AltP,
       'Alt+u'          : _AltU,
       'Ctrl+Alt+Enter' : _CtrlAltEnter,
       'Ctrl+Alt+p'     : _CtrlAltP,
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

// TODO (TL): Temporary hacks until we've bus'ified everything in this file
void _AltG(_) {
  Call.hangup(Model.Call.currentCall);
}

void _AltL(_) {
  Call.park(Model.Call.currentCall);
}

void _AltO(_) {
  Call.transfer(Model.Call.currentCall, Model.CallList.instance.firstParkedCall);
}

void _AltP(_) {
  Call.pickupNext();
}

void _AltU(_) {
  Call.pickupParked(Model.CallList.instance.firstParkedCall);
}

void _CtrlAltEnter(_) {
  User.signalReady();
}

void _CtrlAltP(_) {
  User.signalPaused();
}
