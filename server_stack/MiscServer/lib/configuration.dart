library miscserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:Utilities/common.dart';

Configuration config;

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  String     _bobconfigfile = 'bob_configuration.json';
  String     _configfile    = 'config.json';
  int        _httpport      = 8080;

  String get bobConfigfile => _bobconfigfile;
  String get configfile    => _configfile;
  int    get httpport      => _httpport;

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

      if(config.containsKey('httpport')) {
        _httpport = config['httpport'];
      }
      
      if(config.containsKey('bobconfigfile')) {
        _bobconfigfile = config['bobconfigfile'];
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
      
      if(hasArgument('bobconfigfile')) {
        _bobconfigfile = _args['bobconfigfile'];
      }

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  void _outputConfig() {
    print('''
httpport:      $httpport
bobconfigfile: $bobConfigfile''');
  }

  Future whenLoaded() {
    return _parseConfigFile()
        .whenComplete(_parseArgument)
        .then((_) => _outputConfig());
  }
}
