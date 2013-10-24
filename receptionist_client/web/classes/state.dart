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

import 'events.dart' as event;
import 'logger.dart';

const int _ERROR   = -1;
const int _UNKNOWN = 0;
const int _OK      = 1;

State _state = new State();

State get state => _state;

/**
 * Describes the state of bob.
 */
class State {
  bool _immutable         = false;
  int  _config            = _UNKNOWN;
  int  _logger            = _UNKNOWN;
  bool _scheduledShutdown = false;
  int  _websocket         = _UNKNOWN;

  bool get isConfigurationOK    => _config == _OK;
  bool get isConfigurationError => _config == _ERROR;
  bool get isError              => _getOverallState() == _ERROR;
  bool get isOK                 => _getOverallState() == _OK;
  bool get isUnknown            => _getOverallState() == _UNKNOWN;
  bool get isScheduledShutdown  => _scheduledShutdown;
  bool get isWebsocketError     => _websocket == _ERROR;

  /**
   * Clones myself.
   */
  State _clone() {
    return new State()
      .._immutable = true
      .._config    = _config
      .._logger    = _logger
      .._websocket = _websocket;
  }

  /**
   * Update configuration state to OK
   */
  void configurationOK() {
    if (_immutable) {
      throw new Exception('configurationOK not allowed. Bobstate is immutable');
    }

    _config = _OK;
    _update();
  }

  /**
   * Update configuration state to error
   */
  void configurationError() {
    if (_immutable) {
      throw new Exception('configurationError not allowed. Bobstate is immutable');
    }

    _config = _ERROR;
    _update();
  }

  /**
   * Gives an overall state
   */
  int _getOverallState() {
    if (!_scheduledShutdown) {
      if (_config == _OK && _logger == _OK && _websocket == _OK) {
        return _OK;

      } else if (_config == _ERROR || _logger == _ERROR || _websocket == _ERROR) {
        return _ERROR;

      } else {
        return _UNKNOWN;
      }
    } else {
      return _OK;
    }
  }

  void loggerError() {
    if (_immutable) {
      throw new Exception('loggerError not allowed. Bobstate is immutable');
    }

    _logger = _ERROR;
    _update();
  }

  void loggerOK() {
    if (_immutable) {
      throw new Exception('loggerOK not allowed. Bobstate is immutable');
    }

    _logger = _OK;
    _update();
  }

  /**
   * Signal that a shutdown is coming.
   */
  void scheduleShutdown() {
    if (_immutable) {
      throw new Exception('scheduleShutdown not allowed. Bobstate is immutable');
    }

    _scheduledShutdown = true;
    _update();
  }

  String toString() {
    return 'BobState configuration: ${_config} websocket: ${_websocket} overall: ${_getOverallState()}';
  }

  /**
   * Update websocket state to OK
   */
  void websocketOK() {
    if (_immutable) {
      throw new Exception('websocketOK not allowed. Bobstate is immutable');
    }

    _websocket = _OK;
    _update();
  }

  /**
   * Update websocket state to error
   */
  void websocketError() {
    if (_immutable) {
      throw new Exception('websocketError not allowed. Bobstate is immutable');
    }

    _websocket = _ERROR;
    _update();
  }

  /**
   * Updates the overall statevalue for Bob.
   */
  void _update() {
    log.debug('State updated ${this}');
    event.bus.fire(event.stateUpdated, _clone());
  }
}
