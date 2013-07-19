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

library configuration;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;

import 'package:logging/logging.dart';
import 'package:web_ui/web_ui.dart';

import 'common.dart';
import 'logger.dart';
import 'state.dart';

const String CONFIGURATION_URL = 'http://alice.adaheads.com:4242/configuration';

final _Configuration configuration = new _Configuration();

/**
 * _Configuration gives access to configuration parameters provided by Alice.
 */
class _Configuration {
  @observable bool _loaded = false;

  String   _agentID;
  Uri      _aliceBaseUrl;
  Uri      _notificationSocketInterface;
  Duration _notificationSocketReconnectInterval;
  Level    _serverLogLevel = Level.OFF;
  Uri      _serverLogInterfaceCritical;
  Uri      _serverLogInterfaceError;
  Uri      _serverLogInterfaceInfo;
  String   _standardGreeting;
  int      _userLogSizeLimit = 100000;

  String   get agentID =>                             _agentID;
  Uri      get aliceBaseUrl =>                        _aliceBaseUrl;
  Uri      get notificationSocketInterface =>         _notificationSocketInterface;
  Duration get notificationSocketReconnectInterval => _notificationSocketReconnectInterval;
  Level    get serverLogLevel =>                      _serverLogLevel;
  Uri      get serverLogInterfaceCritical =>          _serverLogInterfaceCritical;
  Uri      get serverLogInterfaceError =>             _serverLogInterfaceError;
  Uri      get serverLogInterfaceInfo =>              _serverLogInterfaceInfo;
  String   get standardGreeting =>                    _standardGreeting;
  int      get userLogSizeLimit =>                    _userLogSizeLimit;

  /**
   * [_Configuration] constructor. Initialize the object with the values from
   * [CONFIGURATION_URL]. Logs a critical error if the request fails.
   */
  _Configuration() {
    fetch();
  }

  void fetch() {
    if(!isLoaded()) {
      HttpRequest.request(CONFIGURATION_URL)
        .then(_onComplete)
        .catchError((error) {
          if (!state.isConfigurationError) {
            log.critical('_Configuration() HttpRequest.request failed with ${error} url: ${CONFIGURATION_URL}');
            state.configurationError();
          }
          new Timer(new Duration(seconds:5),() => fetch());
        });
    }
  }

  /**
   * Is the configuration loaded.
   */
  bool isLoaded() => _loaded;

  /**
   * If [req] status is 200 OK then parse the [req] responseText as JSON and set
   * [loaded] to true, else log an error.
   */
  void _onComplete(HttpRequest req) {
    switch(req.status) {
      case 200:
        _parseConfiguration(json.parse(req.responseText));
        _loaded = true;
        state.configurationOK();
        break;

      default:
        if (!state.isConfigurationError) {
          log.critical('_Configuration._onComplete failed ${CONFIGURATION_URL}-${req.status}-${req.statusText}');
          state.configurationError();
        }
    }
  }

  /**
   * Parse and validate the configuration JSON from Alice.
   */
  void _parseConfiguration(Map json) {
    log.debug('_Configuration._parseConfiguration ${json}');

    String    criticalPath;
    String    errorPath;
    String    infoPath;
    final Map notificationSocketMap = json['notificationSocket'];
    final Map serverLogMap = json['serverLog'];

    _agentID      = _stringValue(json, 'agentID', '0');
    _aliceBaseUrl = Uri.parse(_stringValue(json, 'aliceBaseUrl', 'http://alice.adaheads.com:4242'));

    if (notificationSocketMap['reconnectInterval'] is int && notificationSocketMap['reconnectInterval'] >= 1000) {
      _notificationSocketReconnectInterval =  new Duration(milliseconds: notificationSocketMap['reconnectInterval']);
    } else {
      notificationSocketMap['reconnectInterval'] = new Duration(seconds: 2);
    }

    _notificationSocketInterface = Uri.parse(_stringValue(notificationSocketMap,
                                             'interface',
                                             'ws://alice.adaheads.com:4242/notifications'));

    switch (serverLogMap['level'].toLowerCase()) {
      case 'info':
        _serverLogLevel = Log.INFO;
        break;

      case 'error':
        _serverLogLevel = Log.ERROR;
        break;

      case 'critical':
        _serverLogLevel = Log.CRITICAL;
        break;

      default:
        _serverLogLevel = Level.INFO;
        log.error('_Configuration._parseConfiguration INVALID level ${serverLogMap['level']} - defaulting to Level.INFO');
    }

    criticalPath = _stringValue(serverLogMap['interface'], 'critical', '/log/critical');
    _serverLogInterfaceCritical = Uri.parse('${aliceBaseUrl}${criticalPath}');

    errorPath = _stringValue(serverLogMap['interface'], 'error', '/log/error');
    _serverLogInterfaceError = Uri.parse('${aliceBaseUrl}${errorPath}');

    infoPath = _stringValue(serverLogMap['interface'], 'info', '/log/info');
    _serverLogInterfaceInfo = Uri.parse('${aliceBaseUrl}${infoPath}');

    _standardGreeting = _stringValue(json, 'standardGreeting', 'Velkommen til...');
  }

  /**
   * Return a Duration from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is a bool, return the found bool.
   * if [key] is not found or does not validate as a bool, return [defaultValue].
   */
  bool _boolValue (Map configMap, String key, bool defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is bool)) {
      return configMap[key];

    } else {
      log.error('_Configuration._boolValue ${key} is not a bool, its ${configMap[key].runtimeType}');
      return defaultValue;
    }
  }

  /**
   * Return an int from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is an int, return the found int.
   * if [key] is not found or does not validate as an int, return [defaultValue].
   */
  int _intValue (Map configMap, String key, int defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is int)) {
      return configMap[key];

    } else {
      log.error('_Configuration._intValue ${key} is not an int, its ${configMap[key].runtimeType}');
      return defaultValue;
    }
  }

  /**
   * Return a String from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is a String, return the found String.
   * if [key] is not found or does not validate as a String, return [defaultValue].
   *
   * NOTE: The [defaultValue] is returned if the found String is empty.
   */
  String _stringValue (Map configMap, String key, String defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is String)) {
      return (configMap[key].trim().isEmpty) ? defaultValue : configMap[key];

    } else {
      log.error("_Configuration._stringValue ${key} is not a String, its ${configMap[key].runtimeType}");
      return defaultValue;
    }
  }
}
