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
 * Setup global keyboard shortcuts and associated event streams.
 */
class HotKeys {
  static final HotKeys _singleton = new HotKeys._internal();
  factory HotKeys() => _singleton;

  final Keyboard _keyDown = new Keyboard();

  final Bus<Html.KeyboardEvent> _altA = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altArrowDown = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altArrowUp = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altB = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altC = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altE = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altF = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altH = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altI = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altK = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altM = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altQ = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altS = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altT = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altV = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altW = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _altX = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _ctrlAltEnter = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _ctrlAltP = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _ctrlNumMinus = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _f1 = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _f7 = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _f8 = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _f9 = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _numDiv = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _numMult = new Bus<Html.KeyboardEvent>();
  final Bus<Html.KeyboardEvent> _numPlus = new Bus<Html.KeyboardEvent>();

  Stream<Html.KeyboardEvent> get onAltA => _altA.stream;
  Stream<Html.KeyboardEvent> get onAltArrowDown => _altArrowDown.stream;
  Stream<Html.KeyboardEvent> get onAltArrowUp => _altArrowUp.stream;
  Stream<Html.KeyboardEvent> get onAltB => _altB.stream;
  Stream<Html.KeyboardEvent> get onAltC => _altC.stream;
  Stream<Html.KeyboardEvent> get onAltE => _altE.stream;
  Stream<Html.KeyboardEvent> get onAltF => _altF.stream;
  Stream<Html.KeyboardEvent> get onAltH => _altH.stream;
  Stream<Html.KeyboardEvent> get onAltI => _altI.stream;
  Stream<Html.KeyboardEvent> get onAltK => _altK.stream;
  Stream<Html.KeyboardEvent> get onAltM => _altM.stream;
  Stream<Html.KeyboardEvent> get onAltQ => _altQ.stream;
  Stream<Html.KeyboardEvent> get onAltS => _altS.stream;
  Stream<Html.KeyboardEvent> get onAltT => _altT.stream;
  Stream<Html.KeyboardEvent> get onAltV => _altV.stream;
  Stream<Html.KeyboardEvent> get onAltW => _altW.stream;
  Stream<Html.KeyboardEvent> get onAltX => _altX.stream;
  Stream<Html.KeyboardEvent> get onCtrlAltEnter => _ctrlAltEnter.stream;
  Stream<Html.KeyboardEvent> get onCtrlAltP => _ctrlAltP.stream;
  Stream<Html.KeyboardEvent> get onCtrlNumMinus => _ctrlNumMinus.stream;
  Stream<Html.KeyboardEvent> get onF1 => _f1.stream;
  Stream<Html.KeyboardEvent> get onF7 => _f7.stream;
  Stream<Html.KeyboardEvent> get onF8 => _f8.stream;
  Stream<Html.KeyboardEvent> get onF9 => _f9.stream;
  Stream<Html.KeyboardEvent> get onNumDiv => _numDiv.stream;
  Stream<Html.KeyboardEvent> get onNumMult => _numMult.stream;
  Stream<Html.KeyboardEvent> get onNumPlus => _numPlus.stream;

  /**
   * Internal constructor.
   */
  HotKeys._internal() {
    Html.window.document.onKeyDown.listen(_keyDown.press);

    final Map<dynamic, Html.EventListener> preventDefaultBindings = {
      'Alt+a': _altA.fire,
      'Alt+Down': _altArrowDown.fire,
      'Alt+Up': _altArrowUp.fire,
      'Alt+b': _altB.fire,
      'Alt+c': _altC.fire,
      'Alt+e': _altE.fire,
      'Alt+f': _altF.fire,
      'Alt+h': _altH.fire,
      'Alt+i': _altI.fire,
      'Alt+k': _altK.fire,
      'Alt+m': _altM.fire,
      'Alt+q': _altQ.fire,
      'Alt+s': _altS.fire,
      'Alt+t': _altT.fire,
      'Alt+v': _altV.fire,
      'Alt+w': _altW.fire,
      'Alt+x': _altX.fire,
      'Ctrl+Alt+Enter': _ctrlAltEnter.fire,
      'Ctrl+a': _null, // Blackhole this
      'Ctrl+d': _null, // Blackhole this
      'Ctrl+e': _null, // Blackhole this
      'Ctrl+k': _null, // Blackhole this
      'Ctrl+l': _null, // Blackhole this
      'Ctrl+s': _null, // Blackhole this
      [Key.Ctrl, Key.NumPlus]: _null, // Blackhole this
      'Ctrl+Alt+P': _ctrlAltP.fire,
      [Key.Ctrl, Key.NumMinus]: _ctrlNumMinus.fire,
      'F1': _f1.fire,
      'F7': _f7.fire,
      'F8': _f8.fire,
      'F9': _f9.fire,
      [Key.NumPlus]: _numPlus.fire,
      [Key.NumDiv]: _numDiv.fire,
      [Key.NumMult]: _numMult.fire
    };

    registerKeysPreventDefault(_keyDown, preventDefaultBindings);
  }

  /**
   * Black hole for hotkey combos we don't want.
   */
  void _null(_) => null;

  /**
   * Register the [keyMap] keybindings to [keyboard].
   */
  void registerKeys(Keyboard keyboard, Map<dynamic, Html.EventListener> keyMap) {
    keyMap.forEach((dynamic key, Html.EventListener callback) {
      keyboard.register(key, callback);
    });
  }

  /**
   * Register the [keyMap] key bindings to [keyboard]. Prevent default on all
   * key events.
   */
  void registerKeysPreventDefault(Keyboard keyboard, Map<dynamic, Html.EventListener> keyMap) {
    keyMap.forEach((dynamic key, Html.EventListener callback) {
      keyboard.register(key, (Html.Event event) {
        event.preventDefault();
        callback(event);
      });
    });
  }
}

/**
 * Convenience methods to push events unto the various hotkeys busses without
 * having an actual keyboard event.
 */
class SimulationHotKeys {
  final HotKeys _hotKeys;

  /**
   * Constructor
   */
  SimulationHotKeys(HotKeys this._hotKeys);

  void altA() => _hotKeys._altA.fire(null);
  void altArrowDown() => _hotKeys._altArrowDown.fire(null);
  void altArrowUp() => _hotKeys._altArrowUp.fire(null);
  void altB() => _hotKeys._altB.fire(null);
  void altC() => _hotKeys._altC.fire(null);
  void altE() => _hotKeys._altE.fire(null);
  void altF() => _hotKeys._altF.fire(null);
  void altH() => _hotKeys._altH.fire(null);
  void altI() => _hotKeys._altI.fire(null);
  void altK() => _hotKeys._altK.fire(null);
  void altM() => _hotKeys._altM.fire(null);
  void altQ() => _hotKeys._altQ.fire(null);
  void altS() => _hotKeys._altS.fire(null);
  void altT() => _hotKeys._altT.fire(null);
  void altV() => _hotKeys._altV.fire(null);
  void altW() => _hotKeys._altW.fire(null);
  void altX() => _hotKeys._altX.fire(null);
  void ctrlAltEnter() => _hotKeys._ctrlAltEnter.fire(null);
  void ctrlAltP() => _hotKeys._ctrlAltP.fire(null);
  void ctrlNumMinus() => _hotKeys._ctrlNumMinus.fire(null);
  void f1() => _hotKeys._f1.fire(null);
  void f7() => _hotKeys._f7.fire(null);
  void f8() => _hotKeys._f8.fire(null);
  void f9() => _hotKeys._f9.fire(null);
  void numDiv() => _hotKeys._numDiv.fire(null);
  void numMult() => _hotKeys._numMult.fire(null);
  void numPlus() => _hotKeys._numPlus.fire(null);
}
