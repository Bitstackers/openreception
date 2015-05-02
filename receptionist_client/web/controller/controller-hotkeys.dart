/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of controller;

/**
 * TODO (TL): Comment
 */
class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  final Keyboard _keyDown = new Keyboard();

  final Bus<KeyboardEvent> _altA         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altB         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altC         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altE         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altF         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altH         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altI         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altK         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altM         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altQ         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altS         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altT         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altV         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altW         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _altX         = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _ctrlAltEnter = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _ctrlAltP     = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _f1           = new Bus<KeyboardEvent>();

  Stream<KeyboardEvent> get onAltA         => _altA.stream;
  Stream<KeyboardEvent> get onAltB         => _altB.stream;
  Stream<KeyboardEvent> get onAltC         => _altC.stream;
  Stream<KeyboardEvent> get onAltE         => _altE.stream;
  Stream<KeyboardEvent> get onAltF         => _altF.stream;
  Stream<KeyboardEvent> get onAltH         => _altH.stream;
  Stream<KeyboardEvent> get onAltI         => _altI.stream;
  Stream<KeyboardEvent> get onAltK         => _altK.stream;
  Stream<KeyboardEvent> get onAltM         => _altM.stream;
  Stream<KeyboardEvent> get onAltQ         => _altQ.stream;
  Stream<KeyboardEvent> get onAltS         => _altS.stream;
  Stream<KeyboardEvent> get onAltT         => _altT.stream;
  Stream<KeyboardEvent> get onAltV         => _altV.stream;
  Stream<KeyboardEvent> get onAltW         => _altW.stream;
  Stream<KeyboardEvent> get onAltX         => _altX.stream;
  Stream<KeyboardEvent> get onCtrlAltEnter => _ctrlAltEnter.stream;
  Stream<KeyboardEvent> get onCtrlAltP     => _ctrlAltP.stream;
  Stream<KeyboardEvent> get onF1           => _f1.stream;

  /**
   * Internal constructor.
   */
  HotKeys._internal() {
    window.document.onKeyDown.listen(_keyDown.press);

    final Map<String, EventListener> preventDefaultBindings =
      {'Alt+a'         : _altA.fire,
       'Alt+b'         : _altB.fire,
       'Alt+c'         : _altC.fire,
       'Alt+e'         : _altE.fire,
       'Alt+f'         : _altF.fire,
       'Alt+h'         : _altH.fire,
       'Alt+i'         : _altI.fire,
       'Alt+k'         : _altK.fire,
       'Alt+m'         : _altM.fire,
       'Alt+q'         : _altQ.fire,
       'Alt+s'         : _altS.fire,
       'Alt+t'         : _altT.fire,
       'Alt+v'         : _altV.fire,
       'Alt+w'         : _altW.fire,
       'Alt+x'         : _altX.fire,
       'Ctrl+Alt+Enter': _ctrlAltEnter.fire,
       'Ctrl+d'        : _null, // Blackhole this
       'Ctrl+l'        : _null, // Blackhole this
       'Ctrl+Alt+P'    : _ctrlAltP.fire,
       'F1'            : _f1.fire};

    registerKeysPreventDefault(_keyDown, preventDefaultBindings);
  }

  /**
   * Black hole for hotkey combos we don't want.
   */
  void _null(_) => null;

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
