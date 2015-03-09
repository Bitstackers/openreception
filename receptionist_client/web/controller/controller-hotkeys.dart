part of controller;

class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  Keyboard _keyDown = new Keyboard();

  Bus<KeyboardEvent> _CtrlE = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _CtrlS = new Bus<KeyboardEvent>();

  Stream<KeyboardEvent> get onCtrlE => _CtrlE.stream;
  Stream<KeyboardEvent> get onCtrlS => _CtrlS.stream;

  HotKeys._internal() {
    window.document.onKeyDown.listen(_keyDown.press);

    Map<String, EventListener> keyDownBindings =
      {'Ctrl+e' : _CtrlE.fire,
       'Ctrl+s' : _CtrlS.fire};

    keyDownBindings.forEach((key, callback) {
      _keyDown.register(key, (KeyboardEvent event) {
        event.preventDefault();
        callback(event);
      });
    });
  }
}
