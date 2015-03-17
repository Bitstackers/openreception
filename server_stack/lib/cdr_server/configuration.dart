library messagedispatcher.configuration;

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
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost     = 'localhost';
  int        _dbport     = 5432;
  String     _dbname;
  int        _httpport   = 4080;

  Uri    get authUrl    => _authUrl;
  String get configfile => _configfile;
  String get dbuser     => _dbuser;
  String get dbpassword => _dbpassword;
  String get dbhost     => _dbhost;
  int    get dbport     => _dbport;
  String get dbname     => _dbname;
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

      if(config.containsKey('cdr_server_http_port')) {
        _httpport = config['cdr_server_http_port'];
      }

      if(config.containsKey('dbuser')) {
        _dbuser = config['dbuser'];
      }

      if(config.containsKey('dbpassword')) {
        _dbpassword = config['dbpassword'];
      }

      if(config.containsKey('dbhost')) {
        _dbhost = config['dbhost'];
      }

      if(config.containsKey('dbport')) {
        _dbport = config['dbport'];
      }

      if(config.containsKey('dbname')) {
        _dbname = config['dbname'];
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

      if(hasArgument('dbuser')) {
        _dbuser = _args['dbuser'];
      }

      if(hasArgument('dbpassword')) {
        _dbpassword = _args['dbpassword'];
      }

      if(hasArgument('dbhost')) {
        _dbhost = _args['dbhost'];
      }

      if(hasArgument('dbport')) {
        _dbport = int.parse(_args['dbport']);
      }

      if(hasArgument('dbname')) {
        _dbname = _args['dbname'];
      }

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  void _outputConfig() {
    print('''
httpport:   $httpport
dbuser:     $dbuser
dbpassword: ${dbpassword != null && dbpassword.isNotEmpty ? dbpassword.split('').first +
    dbpassword.split('').skip(1).take(dbpassword.length-2).map((_) => '*').join('') +
    dbpassword.substring(dbpassword.length -1) : ''}
dbhost:     $dbhost
dbport:     $dbport
dbname:     $dbname
''');
  }

  Future whenLoaded() {
    return _parseConfigFile()
        .whenComplete(_parseArgument)
        .then((_) => _outputConfig());
  }
}
