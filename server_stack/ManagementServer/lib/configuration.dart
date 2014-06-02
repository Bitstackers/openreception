library Adaheads.server.configuration;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

class Configuration {
  ArgResults _args;

  Uri        _authUrl;
  String     _configfile;
  int        _httpport   = 8080;
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost;
  int        _dbport;
  String     _dbname;

  Uri    get authUrl        => _authUrl;
  String get configfile     => _configfile;
  String get dbuser         => _dbuser;
  String get dbpassword     => _dbpassword;
  String get dbhost         => _dbhost;
  int    get dbport         => _dbport;
  String get dbname         => _dbname;
  int    get httpport       => _httpport;

  Configuration(ArgResults args) {
    _args = args;
  }

  void parse() {
    if(_hasArgument('configfile')) {
      _configfile = _args['configfile'];
      _parseFile();
    }
    _parseCLA();
    _validate();
  }

  void _parseCLA() {
    if(_hasArgument('authurl')) {
      _authUrl = Uri.parse(_args['authurl']);
    }

    if(_hasArgument('dbhost')) {
      _dbhost = _args['dbhost'];
    }

    if(_hasArgument('dbname')) {
      _dbname = _args['dbname'];
    }

    if(_hasArgument('dbpassword')) {
      _dbpassword = _args['dbpassword'];
    }

    if(_hasArgument('dbport')) {
      _dbport = int.parse(_args['dbport']);
    }

    if(_hasArgument('dbuser')) {
      _dbuser = _args['dbuser'];
    }

    if(_hasArgument('httpport')) {
      _httpport = int.parse(_args['httpport']);
    }

  }

  void _parseFile() {
    if(configfile == null) {
      return;
    }

    File file = new File(configfile);
    String rawContent = file.readAsStringSync();

    Map content = JSON.decode(rawContent);

    if(content.containsKey('authurl')) {
      _authUrl = Uri.parse(content['authurl']);
    }

    if(content.containsKey('dbhost')) {
      _dbhost = content['dbhost'];
    }

    if(content.containsKey('dbname')) {
      _dbname = content['dbname'];
    }

    if(content.containsKey('dbpassword')) {
      _dbpassword = content['dbpassword'];
    }

    if(content.containsKey('dbport')) {
      _dbport = content['dbport'];
    }

    if(content.containsKey('dbuser')) {
      _dbuser = content['dbuser'];
    }

    if(content.containsKey('httpport')) {
      _httpport = content['httpport'];
    }
  }

  void _validate() {
    if(authUrl == null) {
      throw('authurl is not specified.');
    }

    if(dbhost == null) {
      throw('dbhost is not specified.');
    }

    if(dbname == null) {
      throw('dbname is not specified.');
    }

    if(dbpassword == null) {
      throw('dbpassword is not specified.');
    }

    if(dbport == null) {
      throw('dbport is not specified.');
    }

    if(dbuser == null) {
      throw('dbuser is not specified.');
    }

    if(httpport == null) {
      throw('httpport is not specified.');
    }
  }

  String toString() => '''
    AuthUrl: $authUrl
    HttpPort: $httpport
    Database:
      Host: $dbhost
      Port: $dbport
      User: $dbuser
      Pass: ${dbpassword.codeUnits.map((_) => '*').join()}
      Name: $dbname      
    ''';

  bool _hasArgument(String key) {
    assert(_args != null);
    return _args.options.contains(key) && _args[key] != null;
  }
}