library receptionserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

Logger log = new Logger('receptionserver.json_configuration');

Configuration config;

/**
 * Default configuration values.
 */
abstract class Default {
  static final Uri    authenticationServer = Uri.parse("http://localhost:8080");
  static final String configFile           = 'config.json';
  static final int    dbport               = 5432;
  static final String dbhost               = 'localhost';
  static final int    httpport             = 4010;
  static final Uri    notificationServer   = Uri.parse("http://localhost:4200");
  static final String serverToken          = 'feedabbadeadbeef0';
  static final String syslogHost           = 'localhost';
  static final bool   useSyslog = false;
}

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  Uri        _authUrl            = Default.authenticationServer;
  Uri        _notificationServer = Default.notificationServer;
  String     _configfile         = Default.configFile;
  int        _httpport           = Default.httpport;
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost             = Default.dbhost;
  int        _dbport             = Default.dbport;
  String     _dbname;
  String     _cache;
  bool       _useSyslog          = Default.useSyslog;
  String     _serverToken        = Default.serverToken;
  String     _syslogHost         = Default.syslogHost;

  Uri    get authUrl            => _authUrl;
  String get cache              => _cache;
  String get configfile         => _configfile;
  String get dbuser             => _dbuser;
  String get dbpassword         => _dbpassword;
  String get dbhost             => _dbhost;
  int    get dbport             => _dbport;
  String get dbname             => _dbname;
  int    get httpport           => _httpport;
  Uri    get notificationServer => _notificationServer;
  bool   get useSyslog          => _useSyslog;
  String get serverToken        => _serverToken;
  String get syslogHost         => _syslogHost;

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
        if(_authUrl.host == null || _authUrl.host.isEmpty) {
          throw('Invalid authUrl missing host. ${_authUrl}');
        }
      }

      if(config.containsKey('cache')) {
        if(config['cache'].endsWith('/')) {
          _cache = config['cache'];
        } else {
          _cache = '${config['cache']}/';
        }
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

      if(config.containsKey('reception_http_port')) {
        _httpport = config['reception_http_port'];
      }

      if(config.containsKey('notificationServer')) {
        _notificationServer = Uri.parse(config['notificationServer']);
      }

      if(config.containsKey('sysloghost')) {
        _syslogHost = config['sysloghost'];
      }

    })
    .catchError((err, stackTrace) {
      log.shout('Failed to read "$configfile".', err, stackTrace);
    });
  }

  Future _parseArgument() {
    return new Future(() {
      if(hasArgument('authurl')) {
        _authUrl = Uri.parse(_args['authurl']);
        if(_authUrl.host == null || _authUrl.host.isEmpty) {
          throw('Invalid authUrl missing host. ${_authUrl}');
        }
      }

      if(hasArgument('cache')) {
        if(_args['cache'].endsWith('/')) {
          _cache = _args['cache'];
        } else {
          _cache = '${_args['cache']}/';
        }
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

      _useSyslog = _args['syslog'];

      if(hasArgument('sysloghost')) {
        _syslogHost = _args['sysloghost'];
      }

      if(hasArgument('servertoken')) {
        _serverToken = _args['servertoken'];
      }

    }).catchError((error, stackTrace) {
      log.shout('Failed to read "$configfile".', error, stackTrace);
      throw error;
    });
  }

  String toString() => '''
    httpport:     $httpport
    databasehost: $dbhost
    databasename: $dbname
    authurl:      $authUrl
    syslog:       $useSyslog
    sysloghost:   ${syslogHost}''';

  Future whenLoaded() => _parseConfigFile().whenComplete(_parseArgument);
}
