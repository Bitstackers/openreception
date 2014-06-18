library callflowcontrol.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:Utilities/common.dart';

Configuration config;

/**
 * Default configuration values.
 */
abstract class Default {
  static final String configFile           = 'config.json';
  static final int    httpport             = 4243;
  static final Uri    notificationServer   = Uri.parse("http://localhost:4200");
  static final Uri    authenticationServer = Uri.parse("http://localhost:8080");
  static final String callFlowHost         = "localhost";
  static final int    callFlowPort         = 9999;
  static final String serverToken          = 'feedabbadeadbeef0';
}

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  Uri        _authUrl              = Default.authenticationServer;
  Uri        _notificationServer   = Default.notificationServer;
  String     _configfile           = Default.configFile;
  int        _httpport             = Default.httpport;
  String     _callFlowHost         = Default.callFlowHost;
  int        _callFlowPort         = Default.callFlowPort;
  String     _serverToken          = Default.serverToken;

  Uri    get authUrl            => _authUrl;
  Uri    get notificationServer => _notificationServer;
  String get configfile         => _configfile;
  int    get httpport           => _httpport;
  String get callFlowHost       => _callFlowHost;
  int    get callFlowPort       => _callFlowPort;
  String get serverToken        => _serverToken;

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


      if(config.containsKey('httpport')) {
        _httpport = config['httpport'];
      }

      if(config.containsKey('serverToken')) {
        _serverToken = config['serverToken'];
      }

      if(config.containsKey('notificationServer')) {
        _notificationServer = Uri.parse(config['notificationServer']);
      }


      if(config.containsKey('callFlowHost')) {
        _callFlowHost = config['callFlowHost'];
      }

      if(config.containsKey('callFlowPort')) {
        _callFlowPort = config['callFlowPort'];
      }

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

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  void _outputConfig() {
    print('''
authurl  :   $authUrl
httpport :   $httpport
notificationServer :   $notificationServer
configfile : $configfile
callFlowHost : $callFlowHost
callFlowPort : $callFlowPort
''');
  }

  Future whenLoaded() {
    return _parseConfigFile()
        .whenComplete(_parseArgument)
        .then((_) => _outputConfig());
  }
}
