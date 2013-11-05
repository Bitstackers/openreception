/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library keyboard;

import 'dart:async';
import 'dart:html';
import 'logger.dart';

final _KeyboardHandler keyboardHandler = new _KeyboardHandler();

/**
 * [Keys] is a simple mapping between constant literals and integer key codes.
 */
class Keys {
  static const int TAB   =  9;
  static const int ENTER = 13;
  static const int SHIFT = 16;
  static const int CTRL  = 17;
  static const int ALT   = 18;
  static const int ESC   = 27;
  static const int UP    = 38;
  static const int DOWN  = 40;
  static const int ZERO  = 48;
  static const int ONE   = 49;
  static const int TWO   = 50;
  static const int THREE = 51;
  static const int FOUR  = 52;
  static const int FIVE  = 53;
  static const int SIX   = 54;
  static const int SEVEN = 55;
  static const int EIGHT = 56;
  static const int A     = 65;
  static const int B     = 66;
  static const int C     = 67;
  static const int D     = 68;
  static const int E     = 69;
  static const int F     = 70;
  static const int G     = 71;
  static const int H     = 72;
  static const int I     = 73;
  static const int J     = 74;
  static const int K     = 75;
  static const int L     = 76;
  static const int M     = 77;
  static const int N     = 78;
  static const int O     = 79;
  static const int P     = 80;
  static const int Q     = 81;
  static const int R     = 82;
  static const int S     = 83;
  static const int T     = 84;
  static const int U     = 85;
  static const int V     = 86;
  static const int W     = 87;
  static const int X     = 88;
  static const int Y     = 89;
  static const int Z     = 90;
}

/**
 * [_KeyboardHandler] handles sinking of keycodes on associated streams. User of
 * this class may subscribe to these streams using the [onKeyName] method.
 *
 * Using this class guarantees that only ONE key event at a time is processed.
 *
 * NOTE: It is up to the users of this class to decide whether to react on a
 * key events or not. This class merely dump the keycodes of fired key events on
 * a stream.
 */
class _KeyboardHandler {
  Map<int, String>                   _keyToName           = new Map<int, String>();
  Map<String, StreamController<int>> _StreamControllerMap = new Map<String, StreamController<int>>();
  int                                _locked              = null;

  /**
   * [KeyboardHandler] constructor.
   * Initialize (setup named streams) and setup listeners for key events.
   */
  _KeyboardHandler() {
    _initialize();
    _registerEventListeners();
  }

  /**
   * Setup all the keys and their associated streams.
   */
  void _initialize() {
    _keyToName[Keys.ONE]   = 'contexthome';
    _keyToName[Keys.TWO]   = 'contextmessages';
    _keyToName[Keys.THREE] = 'contextlog';
    _keyToName[Keys.FOUR]  = 'contextstatistics';
    _keyToName[Keys.FIVE]  = 'contextphone';
    _keyToName[Keys.SIX]   = 'contextvoicemails';
    _keyToName[Keys.SEVEN] = 'companyevents';
    _keyToName[Keys.EIGHT] = 'companyhandling';
    _keyToName[Keys.UP]    = 'arrowUp';
    _keyToName[Keys.DOWN]  = 'arrowDown';

    _keyToName.forEach((key, value) {
      _StreamControllerMap[value] = new StreamController<int>.broadcast();
    });
  }

  /**
   * Sink a keyCode on a stream if proper conditions are met, ie. the keyCode
   * has a stream associated and the proper control keys are pressed.
   *
   * If the proper conditions are met, a keyCode is emitted on the stream and
   * the class is then locked until a matching keyUp event has been fired. See
   * [_keyUp].
   */
  void _keyDown(KeyboardEvent event) {
    KeyEvent key = new KeyEvent.wrap(event);

    if (_locked == null && (key.ctrlKey && key.altKey)) {
      int keyCode = key.keyCode;

      if(_keyToName.containsKey(keyCode)) {
        _locked = keyCode;
        _StreamControllerMap[_keyToName[keyCode]].sink.add(keyCode);

        log.debug('Sinking key ${keyCode}:${_keyToName[keyCode]}');
      }
    }
  }

  /**
   * Unlocks the [_KeyboardHandler] class if the keyUp event match the keyCode
   * that was used to lock the class in the first place.
   */
  void _keyUp(KeyboardEvent event) {
    KeyEvent key = new KeyEvent.wrap(event);

    if (_locked == key.keyCode) {
      _locked = null;
    }
  }

  /**
   * If [keyName] exists, return a broadcast stream. Else return null.
   *
   * User of this method should take care to handle null returns. Example:
   *
   *  try {
   *    keyboardHandler.onKeyName(id).listen(_keyPress);
   *  } catch(e) {
   *    // handle null return.
   *  }
   */
  Stream<int> onKeyName(String keyName) {
    if (_StreamControllerMap.containsKey(keyName)) {
      return _StreamControllerMap[keyName].stream;
    }

    log.critical('_Keyboardhandler.onKeyName no key ${keyName}');
    return null;
  }

  /**
   * Registers the event listeners.
   */
  void _registerEventListeners() {
    window.onKeyDown.listen(_keyDown);
    window.onKeyUp.listen(_keyUp);
  }
}
