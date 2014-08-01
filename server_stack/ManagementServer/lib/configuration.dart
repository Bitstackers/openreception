library Adaheads.server.configuration;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

abstract class Default {
  static final String configFile           = 'config.json';
  static final int    dbport               = 5432;
  static final String dbhost               = 'localhost';
  static final int    httpport             = 4100;
}

class Configuration {
  ArgResults _args;

  Uri    _authUrl;
  Uri    _callFlowServer;
  String _configfile = Default.configFile;
  String _dbuser;
  String _dbpassword;
  String _dbhost = Default.dbhost;
  int    _dbport = Default.dbport;
  String _dbname;
  Uri    _dialplanCompilerServer;
  int    _httpport   = Default.httpport;
  Uri    _notificationServer;
  String _recordingsDirectory;
  String _token;

  Uri    get authUrl                => _authUrl;
  Uri    get callFlowServer         => _callFlowServer;
  String get configfile             => _configfile;
  String get dbuser                 => _dbuser;
  String get dbpassword             => _dbpassword;
  String get dbhost                 => _dbhost;
  int    get dbport                 => _dbport;
  String get dbname                 => _dbname;
  Uri    get dialplanCompilerServer => _dialplanCompilerServer;
  int    get httpport               => _httpport;
  Uri    get notificationServer     => _notificationServer;
  String get recordingsDirectory    => _recordingsDirectory;
  String get token                  => _token;

  Configuration(ArgResults args) {
    _args = args;
  }

  void parse() {
    if(_hasArgument('configfile')) {
      _configfile = _args['configfile'];
    }
    _parseFile();
    _parseCLA();
    _validate();
  }

  void _parseCLA() {
    if(_hasArgument('authurl')) {
      _authUrl = Uri.parse(_args['authurl']);
    }

    if(_hasArgument('callflowserver')) {
      _callFlowServer = Uri.parse(_args['callflowserver']);
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

    if(_hasArgument('dialplancompilerserver')) {
      _dialplanCompilerServer = Uri.parse(_args['dialplancompilerserver']);
    }

    if(_hasArgument('httpport')) {
      _httpport = int.parse(_args['httpport']);
    }

    if(_hasArgument('notificationserver')) {
      _notificationServer = Uri.parse(_args['notificationserver']);
    }

    if(_hasArgument('recordingsdirectory')) {
      _recordingsDirectory = _args['recordingsdirectory'];
    }

    if(_hasArgument('servertoken')) {
      _token = _args['servertoken'];
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

    if(content.containsKey('callflowserver')) {
      _callFlowServer = Uri.parse(content['callflowserver']);
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

    if(content.containsKey('dialplancompilerserver')) {
      _dialplanCompilerServer = Uri.parse(content['dialplancompilerserver']);
    }

    if(content.containsKey('httpport')) {
      _httpport = content['httpport'];
    }

    if(content.containsKey('notificationserver')) {
      _notificationServer = Uri.parse(content['notificationserver']);
    }

    if(content.containsKey('recordingsdirectory')) {
      _recordingsDirectory = content['recordingsdirectory'];
    }

    if(content.containsKey('servertoken')) {
      _token = content['servertoken'];
    }
  }

  void _validate() {
    if(authUrl == null) {
      throw('authurl is not specified.');
    }

    if(callFlowServer == null) {
      throw('callflowserver is not specified.');
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

    if(dialplanCompilerServer == null) {
      throw('dialplancompilerserver is not specified.');
    }

    if(httpport == null) {
      throw('httpport is not specified.');
    }

    if(notificationServer == null) {
      throw('notificationServer is not specified.');
    }

    if(recordingsDirectory == null) {
      throw('recordingsdirectory is not specified.');
    }
  }

  String toString() => '''
    AuthUrl: $authUrl
    HttpPort: $httpport
    NotificationServer:  $notificationServer
    dialplanserver:      $dialplanCompilerServer
    callflowserver:      $callFlowServer
    recordingsdirectory: ${recordingsDirectory}
    Token: $token
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