library logserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:openreception_framework/common.dart';

Configuration config;

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  Uri        _authUrl;
  String     _configfile = 'config.json';
  int        _httpport   = 8080;

  Uri    get authUrl    => _authUrl;
  String get configfile => _configfile;
  int    get httpport   => _httpport;

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

  void validate() {
    if(authUrl == null) {
      logger.error('authurl is not specified');
      throw('authurl is not specified');
    }

    if(httpport <= 0 || httpport > 65535) {
      throw('invalid httpport');
    }
  }

  String toString() => '''httpport: $httpport''';

  Future whenLoaded() => _parseConfigFile().whenComplete(_parseArgument);
}
