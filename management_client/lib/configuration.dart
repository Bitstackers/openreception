library orm.configuration;

import 'dart:html';

import 'package:orf/model.dart' as model;

Configuration config = new Configuration._internal();

class Configuration {
  Uri get configUri => _localStorage.containsKey('configUri')
      ? Uri.parse(_localStorage['configUri'])
      : Uri.parse('');
  void set configUri(Uri value) {
    _localStorage['configUri'] = value.toString();
  }

  model.ClientConfiguration clientConfig =
      new model.ClientConfiguration.empty();
  Storage _localStorage = window.localStorage;

  model.User user = new model.User.empty();

  String get token =>
      _localStorage.containsKey('authtoken') ? _localStorage['authtoken'] : '';
  void set token(String value) {
    _localStorage['authtoken'] = value;
  }

  Configuration._internal();
}
