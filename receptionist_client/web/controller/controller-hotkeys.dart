part of controller;

class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  Keyboard _keyDown = new Keyboard();

  Bus<KeyboardEvent> _busCtrlE = new Bus<KeyboardEvent>();
  Bus<KeyboardEvent> _busCtrlS = new Bus<KeyboardEvent>();

  Stream<KeyboardEvent> get onCtrlE => _busCtrlE.stream;
  Stream<KeyboardEvent> get onCtrlS => _busCtrlS.stream;

  HotKeys._internal() {
    window.document.onKeyDown.listen(_keyDown.press);

    Map<String, EventListener> keyDownBindings =
      {'Ctrl+e' : _busCtrlE.fire,
       'Ctrl+s' : _busCtrlS.fire};

    keyDownBindings.forEach((key, callback) {
      _keyDown.register(key, (KeyboardEvent event) {
        event.preventDefault();
        callback(event);
      });
    });
  }
}
