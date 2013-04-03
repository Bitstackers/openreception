/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

/**
 * Library to manage keyboardshortcuts.
 */
library keyboard;

import 'dart:html';

import 'common.dart';
import 'logger.dart';

part 'keyboardshortcuts.dart';

/**
 * The one and only [keyboardhandler].
 */
final Keyboardhandler keyboardHandler = new Keyboardhandler._internal();

/**
 * Class to handler keyboard events, and activate the right keyboardshortcuts.
 */
class Keyboardhandler{
  /**
   * Global shortcuts are always active.
   */
  KeyboardShortcuts global;

  /**
   * TODO Comment
   */
  KeyboardShortcuts context;

  /**
   * TODO Comment
   */
  KeyboardShortcuts widget;

  int _locked = null;

  /**
   * Private constructor to make sure there is only one instance of it.
   */
  Keyboardhandler._internal() {
    log.debug('keyboardHanlder Initialized');

    window.onKeyDown.listen(_keyDown);
    window.onKeyUp.listen(_keyUp);
  }

  void _keyDown(KeyboardEvent event) {
    var key = new KeyEvent(event);

    if (_locked == null) {
      if (key.ctrlKey && key.altKey) {
        int keyCode = key.keyCode;

        log.debug('${keyCode} - Ctrl and Alt Down');

        if (widget != null && widget.callIfPresent(keyCode)) {
          _locked = keyCode;

        }else if(context != null && context.callIfPresent(keyCode)) {
          _locked = keyCode;

        }else if(global != null && global.callIfPresent(keyCode)) {
          log.debug('Global Keyboard ${key.keyCode}');
          _locked = keyCode;
        }
      }
    }
  }

  void _keyUp(KeyboardEvent event) {
    var key = new KeyEvent(event);

    if (_locked == key.keyCode){
      _locked = null;
    }
  }
}

/**
 * Contains keyboardskeys for making keyboardshortcuts.
 */
class Keys{
  static const int UP = 38;
  static const int DOWN = 40;
  static const int A = 65;
  static const int B = 66;
  static const int C = 67;
  static const int D = 68;
  static const int E = 69;
  static const int F = 70;
  static const int G = 71;
  static const int H = 72;
  static const int I = 73;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int Q = 81;
  static const int R = 82;
  static const int S = 83;
  static const int T = 84;
  static const int U = 85;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;
}
