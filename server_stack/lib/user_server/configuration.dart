library userserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

Logger log = new Logger('userserver.json_configuration');

Configuration config;


/**
 * Default configuration values.
 */
abstract class Default {
  static final String configFile           = 'config.json';
  static final int    httpport             = 4030;
  static final Uri    notificationServer   = Uri.parse("http://localhost:4200");
  static final Uri    authenticationServer = Uri.parse("http://localhost:8080");
  static final String serverToken          = 'feedabbadeadbeef0';
}

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  Uri        _authUrl            = Default.authenticationServer;
  Uri        _notificationServer = Default.notificationServer;
  String     _configfile         = Default.configFile;
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost     = 'localhost';
  int        _dbport     = 5432;
  String     _dbname;
  int        _httpport   = Default.httpport;
  String     _serverToken          = Default.serverToken;

  Uri    get authUrl            => _authUrl;
  Uri    get notificationServer => _notificationServer;
  String get configfile         => _configfile;
  String get dbuser             => _dbuser;
  String get dbpassword         => _dbpassword;
  String get dbhost             => _dbhost;
  int    get dbport             => _dbport;
  String get dbname             => _dbname;
  int    get httpport           => _httpport;
  String get serverToken        => _serverToken;

  String emailUsername;
  String emailPassword;
  String emailFromName;
  String emailFrom;
  List<String> recipients = [];

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

      if(config.containsKey('user_server_http_port')) {
        _httpport = config['user_server_http_port'];
      }

      if(config.containsKey('serverToken')) {
        _serverToken = config['serverToken'];
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

      if(config.containsKey('notificationServer')) {
        _notificationServer = Uri.parse(config['notificationServer']);
      }

      if(config.containsKey('dbport')) {
        _dbport = config['dbport'];
      }

      if(config.containsKey('dbname')) {
        _dbname = config['dbname'];
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

      if(hasArgument('servertoken')) {
        _serverToken = _args['servertoken'];
      }

    }).catchError((error, stackTrace) {
      log.shout('Failed to read "$configfile".', error, stackTrace);
      throw error;
    });
  }

  @override
  String  toString() =>'''
httpport:   $httpport
dbuser:     $dbuser
dbpassword: ${dbpassword != null && dbpassword.isNotEmpty ? dbpassword.split('').first +
    dbpassword.split('').skip(1).take(dbpassword.length-2).map((_) => '*').join('') +
    dbpassword.substring(dbpassword.length -1) : ''}
dbhost:     $dbhost
dbport:     $dbport
dbname:     $dbname
emailfrom:  $emailFromName <$emailFrom>
mailuser:   $emailUsername
mailpass:   $emailPassword''';

  Future whenLoaded() {
    return _parseConfigFile().whenComplete(_parseArgument);
  }
}
