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
 * In this library we fetch the configuration for Bob.
 */
library configuration;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'dart:uri';

import 'package:logging/logging.dart';

import 'common.dart';
import 'logger.dart';

/**
 * Access to configuration parameters provided by Alice.
 */
class Configuration {
  static Configuration _instance;
  static const String _CONFIGURATION_URL = 'http://alice.adaheads.com:4242/configuration';

  bool _loaded = false;
  bool get loaded => _loaded;

  int _agentID;
  int get agentID => _agentID;

  Uri _aliceBaseUrl;
  Uri get aliceBaseUrl => _aliceBaseUrl;

  Uri _notificationSocketInterface;
  Uri get notificationSocketInterface => _notificationSocketInterface;

  int _notificationSocketReconnectInterval;
  int get notificationSocketReconnectInterval => _notificationSocketReconnectInterval;

  Level _serverLogLevel = Level.OFF;
  Level get serverLogLevel => _serverLogLevel;

  Uri _serverLogInterfaceCritical;
  Uri get serverLogInterfaceCritical => _serverLogInterfaceCritical;

  Uri _serverLogInterfaceError;
  Uri get serverLogInterfaceError => _serverLogInterfaceError;

  Uri _serverLogInterfaceInfo;
  Uri get serverLogInterfaceInfo => _serverLogInterfaceInfo;

  String _standardGreeting;
  String get standardGreeting => _standardGreeting;

  /**
   * Factory for the Configuration singleton.
   */
  factory Configuration() {
    var configUri = new Uri(_CONFIGURATION_URL);

    // TODO Why does it have to be Absolute? couldn't it have a fragment to
    //      indicate the company, or type of user. I just find it a strange restricting.
    assert(configUri.isAbsolute);

    if(_instance == null) {
      _instance = new Configuration._internal(configUri);
    }
    return _instance;
  }

  Configuration._internal(Uri URI) {
    HttpRequest.request(URI.toString())
        ..then(_onComplete,
               onError: (AsyncError error) => log.debug('Configuration request error'))
        .catchError((error) => log.critical('configuration exception ${error.runtimeType.toString()}'));
  }

  void _onComplete(HttpRequest req) {
    switch(req.status) {
      case 200:
        _parseConfiguration(json.parse(req.responseText)['dart']);
        _loaded = true;
        break;
      default:
        log.critical('/Configuration request failed with ${req.status}:${req.statusText}');
    }
  }

  /**
   * Parse and validate the configuration JSON from Alice.
   */
  void _parseConfiguration(Map json){
    _agentID = _intValue (json, 'agentID', 0);
    _aliceBaseUrl = new Uri(_stringValue(json, 'aliceBaseUrl', 'http://alice.adaheads.com:4242'));

    Map notificationSocketMap = json['notificationSocket'];
    _notificationSocketReconnectInterval = _intValue(notificationSocketMap, 'reconnectInterval', 1000);
    _notificationSocketInterface =
        new Uri(_stringValue(notificationSocketMap, 'interface', 'ws://alice.adaheads.com:4242/notifications'));

    Map serverLogMap = json['serverLog'];
    switch (serverLogMap['level'].toLowerCase()){
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
        log.error('Configuration logLevel had the invalid value: ${json['serverLogLevel']}');
        break;
    }

    var criticalPath = _stringValue(serverLogMap['interface'], 'critical', '/log/critical');
    var errorPath = _stringValue(serverLogMap['interface'], 'error', '/log/error');
    var infoPath = _stringValue(serverLogMap['interface'], 'info', '/log/info');

    _serverLogInterfaceCritical = new Uri('${aliceBaseUrl}${criticalPath}');
    _serverLogInterfaceError = new Uri('${aliceBaseUrl}${errorPath}');
    _serverLogInterfaceInfo = new Uri('${aliceBaseUrl}${infoPath}');

    _standardGreeting = _stringValue(json, 'standardGreeting', 'Velkommen til...');
  }

  /**
   * Return a bool from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is a bool, return the found bool.
   * if [key] is not found or does not validate as a bool, return [defaultValue].
   */
  bool _boolValue (Map configMap, String key, bool defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is bool)) {
      return configMap[key];
    } else {
      log.critical('Configuration parameter ${key} does not validate as bool');
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
      log.critical('Configuration parameter ${key} does not validate as int');
      return defaultValue;
    }
  }

  /**
   * Return a String from [configMap] or [defaultValue].
   *
   * If [key] is found in [configMap] and the value is a String, return the found String.
   * if [key] is not found or does not validate as a String, return [defaultValue].
   * Note that [defaultValue] is also returned if the found String is empty.
   */
  String _stringValue (Map configMap, String key, String defaultValue) {
    if ((configMap.containsKey(key)) && (configMap[key] is String)) {
      return (configMap[key].trim().isEmpty) ? defaultValue : configMap[key];
    } else {
      log.critical('Configuration parameter ${key} does not validate as String');
      return defaultValue;
    }
  }
}

/**
 * Fetch the configuration.
 *
 * Completes when [Configuration.loaded] is true.
 */
Future<bool> fetchConfig() {
  var completer = new Completer();

  if (configuration.loaded) {
    completer.complete(true);
  } else {
    final Duration repeatTime = new Duration(milliseconds: 5);
    final Duration maxWait = new Duration(milliseconds: 3000);
    var count = 0;

    new Timer.periodic(repeatTime, (timer) {
      count += 1;
      if (configuration.loaded) {
        timer.cancel();
        completer.complete(true);
      }

      if (count >= maxWait.inMilliseconds/repeatTime.inMilliseconds) {
       timer.cancel();
       completer.completeError(
           new TimeoutException("Could not fetch configuration."));
     }
    });
  }

  return completer.future;
}

final configuration = new Configuration();
