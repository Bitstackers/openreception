/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.configuration_server.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

Logger log = new Logger('miscserver.json_configuration');

Configuration config;

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  String     _configfile    = 'config.json';
  int        _httpport      = 4080;
  Uri        _callFlowServerUri = Uri.parse('http://localhost:4242/');
  Uri        _receptionServerUri = Uri.parse('http://localhost:4000/');
  Uri        _contactServerUri = Uri.parse('http://localhost:4000/');
  Uri        _messageServerUri = Uri.parse('http://localhost:4000/');
  Uri        _logServerUri = Uri.parse('http://localhost:4000/');
  Uri        _authServerUri = Uri.parse('http://localhost:4000/');
  Uri        _notificationSocketUri = Uri.parse('ws://localhost:4200/notifications');
  Uri        _notificationServerUri = Uri.parse('http://localhost:4200');
  String     _systemLanguage = 'en';

  String get systemLanguage => _systemLanguage;
  String get configfile    => _configfile;
  int    get httpport      => _httpport;
  Uri    get callFlowServerUri => _callFlowServerUri;
  Uri    get receptionServerUri => _receptionServerUri;
  Uri    get contactServerUri => _contactServerUri;
  Uri    get messageServerUri => _messageServerUri;
  Uri    get logServerUri => _logServerUri;
  Uri    get authServerUri => _authServerUri;
  Uri    get notificationSocketUri => _notificationSocketUri;
  Uri    get notificationServerUri => _notificationServerUri;

  factory Configuration(ArgResults args) {
    if(_configuration == null) {
      _configuration = new Configuration._internal(args);
    }

    return _configuration;
  }

  Configuration._internal(ArgResults args) {
    _args = args;
    if(hasArgument('configfile')) {
      _configfile = args['configfile'];
    }
  }

  bool hasArgument(String name) {
    try {
      return _args[name] != null && _args[name].trim() != '';
    } catch(e) {
      return false;
    }
  }

  Future _parseConfigFile() {
    File file = new File(_configfile);

    return file.readAsString().then((String data) {
      Map config = JSON.decode(data);


      if(config.containsKey('config_server_http_port')) {
        _httpport = config['config_server_http_port'];
      }

      if(config.containsKey('notificationServer')) {
        _notificationServerUri = Uri.parse(config['notificationServer']);
      }

      if(config.containsKey('callflowserver')) {
        _callFlowServerUri = Uri.parse(config['callflowserver']);
      }

      if(config.containsKey('notificationSocket')) {
        _notificationSocketUri = Uri.parse(config['notificationSocket']);
      }

      if(config.containsKey('receptionServerUri')) {
        _receptionServerUri = Uri.parse(config['receptionServerUri']);
      }

      if(config.containsKey('contactServerUri')) {
        _contactServerUri = Uri.parse(config['contactServerUri']);
      }

      if(config.containsKey('messageServerUri')) {
        _messageServerUri = Uri.parse(config['messageServerUri']);
      }

      if(config.containsKey('authServerUri')) {
        _authServerUri = Uri.parse(config['authServerUri']);
      }

      if(config.containsKey('systemLanguage')) {
        _systemLanguage = config['systemLanguage'];
      }

    })
    .catchError((err, stackTrace) {
      log.shout('Failed to read "$configfile".', err, stackTrace);
    });
  }

  Future _parseArgument() {
    return new Future(() {
      if(hasArgument('httpport')) {
        _httpport = int.parse(_args['httpport']);
      }

    }).catchError((error, stackTrace) {
      log.shout('Failed to read "$configfile".', error, stackTrace);
      throw error;
    });
  }

  String toString() =>'''
  httpport:      $httpport''';

  Future whenLoaded() => _parseConfigFile().whenComplete(_parseArgument).then((_) => print(config));
}
