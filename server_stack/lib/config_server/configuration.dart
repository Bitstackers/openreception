library miscserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:openreception_framework/common.dart';

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

      if(config.containsKey('callflowserver')) {
        _callFlowServerUri = Uri.parse(config['callflowserver']);
      }

      if(config.containsKey('notificationSocketUri')) {
        _notificationSocketUri = Uri.parse(config['notificationSocketUri']);
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
    .catchError((err) {
      log('Failed to read "$configfile". Error: $err');
    });
  }

  Future _parseArgument() {
    return new Future(() {
      if(hasArgument('httpport')) {
        _httpport = int.parse(_args['httpport']);
      }

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  String toString() =>'''
  httpport:      $httpport''';

  Future whenLoaded() => _parseConfigFile().whenComplete(_parseArgument).then((_) => print(config));
}
