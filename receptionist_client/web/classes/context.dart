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

library context;

import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

import 'keyboardhandler.dart';

final StreamController<Context> _contextActivationStream = new StreamController<Context>();
final Stream<Context> _onChange = _contextActivationStream.stream.asBroadcastStream();

/**
 * A [Context] is a container for some content. A [Context] can be active or
 * inactive, defined by the [isActive] property.
 */
class Context {
  @observable int alertCounter = 0;
  @observable bool isActive = false;

  Element _element;

  bool   get alertMode => alertCounter > 0;
  String get id        => _element.id;

  /**
   * A [Context] is a top-level GUI container. It represents a collection of 0
   * or more widgets that are hidden/unhidden depending on the activation state
   * of the [Context].
   */
  Context(Element this._element) {
    assert(_element != null);

    isActive = _element.classes.contains('hidden') ? false : true;

    _onChange.listen(_toggle);

    keyboardHandler.onKeyName(id).listen(_keyPress);
  }

  /**
   * Activate this [Context].
   */
  void activate() => _contextActivationStream.sink.add(this);

  /**
   * Decrease the alert level for this [Context].
   */
  void decreaseAlert() {
    if (alertCounter > 0) {
      alertCounter--;
    }
  }


  /**
   * Increase the alert level for this [Context].
   */
  void increaseAlert() {
    alertCounter++;
  }

  /**
   * Activate this [Context] when the [id] keyboardshortcut fires.
   */
  void _keyPress(int keyCode) => activate();

  /**
   * Toogle this [Context] on/off.
   */
  void _toggle(Context context) {
    if (context == this) {
      isActive = true;
      _element.classes.remove('hidden');
    } else if (isActive) {
      isActive = false;
      _element.classes.add('hidden');
    }
  }
}
