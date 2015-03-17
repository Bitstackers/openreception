library authenticationserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:openreception_framework/common.dart';

Configuration config;

abstract class Configuration_Defaults {
  static final String     configfile      = 'config.json';

  static final String     dbhost          = 'localhost';
  static final int        dbport          = 5432;

  static final int        httpport        = 8081;
  static final Uri        redirectUri     = Uri.parse('http://localhost:8080/oauth2callback');
  static final bool       useSyslog       = false;
  static final String     syslogHost      = 'localhost';
  static final Duration   tokenexpiretime = new Duration(seconds: 3600);
}

class Configuration {

  static Configuration _configuration;

  ArgResults _args;
  String     _cache;
  String     _clientId;
  String     _clientSecret;
  String     _clientURL;
  String     _configfile      = Configuration_Defaults.configfile;
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost          = Configuration_Defaults.dbhost;
  int        _dbport          = Configuration_Defaults.dbport;
  String     _dbname;
  int        _httpport        = Configuration_Defaults.httpport;
  Uri        _redirectUri     = Configuration_Defaults.redirectUri;
  bool       _useSyslog       = Configuration_Defaults.useSyslog;
  String     _serverTokenDir;
  String     _syslogHost      = Configuration_Defaults.syslogHost;
  Duration   _tokenexpiretime = Configuration_Defaults.tokenexpiretime;

  String   get cache           => _cache;
  String   get configfile      => _configfile;
  String   get clientId        => _clientId;
  String   get clientSecret    => _clientSecret;
  String   get clientURL       => _clientURL;
  String   get dbuser          => _dbuser;
  String   get dbpassword      => _dbpassword;
  String   get dbhost          => _dbhost;
  int      get dbport          => _dbport;
  String   get dbname          => _dbname;
  int      get httpport        => _httpport;
  Uri      get redirectUri     => _redirectUri;
  bool     get useSyslog       => _useSyslog;
  String   get serverTokenDir  => _serverTokenDir;
  String   get syslogHost      => _syslogHost;
  Duration get tokenexpiretime => _tokenexpiretime;

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

      if(config.containsKey('cache')) {
        if(config['cache'].endsWith('/')) {
          _cache = config['cache'];
        } else {
          _cache = '${config['cache']}/';
        }
      }

      if(config.containsKey('clientid')) {
        _clientId = config['clientid'];
      }

      if(config.containsKey('clientsecret')) {
        _clientSecret = config['clientsecret'];
      }

      if(config.containsKey('clientURL')) {
        _clientURL= config['clientURL'];
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

      if(config.containsKey('authserver_http_port')) {
        _httpport = config['authserver_http_port'];
      }

      if(config.containsKey('servertokendir')) {
        _serverTokenDir = config['servertokendir'];
      }

      if(config.containsKey('sysloghost')) {
        _syslogHost = config['sysloghost'];
      }

      if(config.containsKey('redirecturi')) {
        _redirectUri = Uri.parse(config['redirecturi']);
      }

      if(config.containsKey('tokenexpiretime')) {
        _tokenexpiretime = new Duration(seconds: config['tokenexpiretime']);
      }

    })
    .catchError((err) {
      log('Failed to read "$configfile". Error: $err');
    });
  }

  Future _parseArgument() {
    return new Future(() {
      if(hasArgument('cache')) {
        if(_args['cache'].endsWith('/')) {
          _cache = _args['cache'];
        } else {
          _cache = '${_args['cache']}/';
        }
      }

      if(hasArgument('clientid')) {
        _clientId = _args['clientid'];
      }

      if(hasArgument('clientsecret')) {
        _clientSecret = _args['clientsecret'];
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

      if(hasArgument('httpport')) {
        _httpport = int.parse(_args['httpport']);
      }

      if(hasArgument('redirecturi')) {
        _redirectUri = Uri.parse(_args['redirecturi']);
      }

      if(hasArgument('servertokendir')) {
        _serverTokenDir = _args['servertokendir'];
      }

      _useSyslog = _args['syslog'];

      if(hasArgument('sysloghost')) {
        _syslogHost = _args['sysloghost'];
      }

      if(hasArgument('tokenexpiretime')) {
        _tokenexpiretime = new Duration(seconds: int.parse(_args['tokenexpiretime']));
      }

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  String toString() => '''
    httpport:       $httpport
    redirecturi:    $redirectUri
    syslog:         $useSyslog
    sysloghost:     ${syslogHost}
    cache:          ${cache}
    ServerTokenDir: ${serverTokenDir}
    Database:
      Host: $dbhost
      Port: $dbport
      User: $dbuser
      Pass: ${dbpassword.codeUnits.map((_) => '*').join()}
      Name: $dbname  ''';

  Future whenLoaded() => _parseConfigFile().whenComplete(_parseArgument);
}
