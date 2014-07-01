library callflowcontrol.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:OpenReceptionFramework/common.dart';

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
  static final String eslPassword          = '1234';
}

class Configuration {
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

  Uri    get authUrl            => _authUrl;
  Uri    get notificationServer => _notificationServer;
  String get configfile         => _configfile;
  int    get httpport           => _httpport;
  String get serverToken        => _serverToken;
  String get eslHostname        => this._eslHostname;
  int    get eslPort            => this._eslPort;
  String get eslPassword        => this._eslPassword;

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

      if(config.containsKey('httpport')) {
        _httpport = config['httpport'];
      }

      if(config.containsKey('notificationServer')) {
        _notificationServer = Uri.parse(config['notificationServer']);
      }

      assert (this.serverToken != null);

    })
    .catchError((err) {
      log('Failed to read "$configfile". Error: $err');
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

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  void _outputConfig() {
    print('''
authurl            :   ${this.authUrl}
httpport           :   ${this.httpport}
notificationServer :   ${this.notificationServer}
configfile         :   ${this.configfile}
eslDSN             :   esl://:${this.eslPassword}@${this.eslHostname}:${this.eslPort}
serverToken        :   ${this.serverToken}''');
  }

  Future whenLoaded() {
    return _parseConfigFile()
        .whenComplete(_parseArgument)
        .then((_) => _outputConfig());
  }
}
