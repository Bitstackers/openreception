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

library openreception.call_flow_control_server.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

abstract class PhoneType {
  static const String SNOM = 'snom';
}

Configuration config;

/**
 * Default configuration values.
 */
abstract class Default {
  static final String configFile           = 'config.json';
  static final int    httpport             = 4243;
  static final Uri    notificationServer   = Uri.parse("http://localhost:4200/");
  static final Uri    authenticationServer = Uri.parse("http://localhost:4050/");
  static final String serverToken          = null;
  static final String eslHostname          = 'localhost';
  static final int    eslPort              = 8021;
  static const String eslPassword          = 'ClueCon';
  static const String phoneType            = PhoneType.SNOM;
  static const String dialoutgateway       = 'trunk.example.com';
}

class Configuration {

  static final Logger log = new Logger ('callflowcontrol.configuration');

  static Configuration _configuration;

  ArgResults _args;
  Uri        _authUrl              = Default.authenticationServer;
  Uri        _notificationServer   = Default.notificationServer;
  String     _configfile           = Default.configFile;
  int        _httpport             = Default.httpport;
  String     _serverToken          = Default.serverToken;
  String     _eslHostname          = Default.eslHostname;
  int        _eslPort              = Default.eslPort;
  String     _eslPassword          = Default.eslPassword;
  String     _dialoutgateway       = Default.dialoutgateway;

  Uri    get authUrl            => _authUrl;
  Uri    get notificationServer => _notificationServer;
  String get configfile         => _configfile;
  int    get httpport           => _httpport;
  String get serverToken        => _serverToken;
  String get eslHostname        => this._eslHostname;
  int    get eslPort            => this._eslPort;
  String get eslPassword        => this._eslPassword;
  String get phoneType          => Default.phoneType;
  String get dialoutgateway     => this._dialoutgateway;

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

      if(config.containsKey('authurl')) {
        _authUrl = Uri.parse(config['authurl']);
      }

      if(config.containsKey('eslHostname')) {
        this._eslHostname = config['eslHostname'];
      }

      if(config.containsKey('eslPort')) {
        this._eslPort = config['eslPort'];
      }

      if(config.containsKey('eslPassword')) {
        this._eslPassword = config['eslPassword'];
      }

      if(config.containsKey('callflow_http_port')) {
        _httpport = config['callflow_http_port'];
      }

      if(config.containsKey('notificationServer')) {
        _notificationServer = Uri.parse(config['notificationServer']);
      }

      if(config.containsKey('dialoutgateway')) {
        _dialoutgateway = config['dialoutgateway'];
      }

      if(config.containsKey('servertoken')) {
        _serverToken = config['servertoken'];
      }
})
    .catchError((error, stackTrace) {
      log.shout ('Failed to read "$configfile".');
      log.shout (error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }

  Future _parseArgument() {
    return new Future(() {
      if(hasArgument('authurl')) {
        _authUrl = Uri.parse(_args['authurl']);
      }

      if(hasArgument('httpport')) {
        _httpport = int.parse(_args['httpport']);
      }

      if(hasArgument('servertoken')) {
        _serverToken = _args['servertoken'];
      }

      assert (this.serverToken != null);

    }).catchError((error, stacktrace) {
      log.shout ('Failed loading commandline arguments.');
      log.shout (error, stacktrace);
      throw error;
    });
  }

  void _outputConfig() {
    log.fine('''
authurl            : ${this.authUrl}
httpport           : ${this.httpport}
notificationServer : ${this.notificationServer}
configfile         : ${this.configfile}
eslDSN             : esl://:${this.eslPassword}@${this.eslHostname}:${this.eslPort}
dailoutgateway     : ${this.dialoutgateway}
serverToken        : ${this.serverToken}''');
  }

  Future whenLoaded() {
    return _parseConfigFile()
        .whenComplete(_parseArgument)
        .then((_) => _outputConfig());
  }
}
