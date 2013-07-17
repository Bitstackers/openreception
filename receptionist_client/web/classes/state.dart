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
library state;

import 'dart:async';

import 'package:web_ui/web_ui.dart';

import 'logger.dart';

final State state = new State();

class State {
  static const int ERROR   = -1;
  static const int UNKNOWN = 0;
  static const int OK      = 1;

              int                   _config            = UNKNOWN;
  final       StreamController<int> _stream            = new StreamController<int>.broadcast();
              bool                  _scheduledShutdown = false;
  @observable int                   _value             = UNKNOWN;
              int                   _websocket         = UNKNOWN;

  Stream<int> get stream            => _stream.stream;
  bool        get scheduledShutdown => _scheduledShutdown;
  int         get value             => _value;

  /**
   * Gives a overall state
   */
  int _getOverallState(){
    if (_scheduledShutdown == false) {
      if (_config == OK && _websocket == OK) {
        return OK;

      } else if (_config == ERROR || _websocket == ERROR) {
        return ERROR;

      } else {
        return UNKNOWN;
      }
    } else {
      return OK;
    }
  }

  /**
   * Updates the state of Bob.
   */
  void update(String name, int state){
    if (name == 'configuration') {
      _config = state;
    } else if (name == 'socket') {
      log.debug('state socket updated!');
      _websocket = state;
    }

    int newValue = _getOverallState();
    if (newValue != _value){
      log.debug('State updated before: ${_value} after: ${newValue}');
      _stream.sink.add(newValue);
    }
    _value = newValue;
  }

  /**
   * Signal that a shutdown is coming.
   */
  void scheduleShutdown() {
    _scheduledShutdown = true;
  }
}