library authenticationserver.configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:Utilities/common.dart';

Configuration config;

class Configuration {
  static Configuration _configuration;

  ArgResults _args;
  String     _cache;
  String     _clientId;
  String     _clientSecret;
  String     _clientURL;
  String     _configfile  = 'config.json';
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost      = 'localhost';
  int        _dbport      = 5432;
  String     _dbname;
  int        _httpport    = 8080;
  Uri        _redirectUri = Uri.parse('http://localhost:8080/oauth2callback');
  Duration   _tokenexpiretime = new Duration(seconds: 3600);

  String get cache        => _cache;
  String get configfile   => _configfile;
  String get clientId     => _clientId;
  String get clientSecret => _clientSecret;
  String get clientURL    => _clientURL;
  String get dbuser       => _dbuser;
  String get dbpassword   => _dbpassword;
  String get dbhost       => _dbhost;
  int    get dbport       => _dbport;
  String get dbname       => _dbname;
  int    get httpport     => _httpport;
  Uri    get redirectUri  => _redirectUri;
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

      if(config.containsKey('httpport')) {
        _httpport = config['httpport'];
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

      if(hasArgument('tokenexpiretime')) {
        _tokenexpiretime = new Duration(seconds: int.parse(_args['tokenexpiretime']));
      }

    }).catchError((error) {
      log('Failed loading commandline arguments. $error');
      throw error;
    });
  }

  String toString() => '''
    httpport:    $httpport
    redirecturi: $redirectUri''';

  Future whenLoaded() => _parseConfigFile().whenComplete(_parseArgument).then((_) => log(config));
}
