library management_tool.configuration;

import 'dart:html';
import 'package:openreception.framework/model.dart' as model;

Configuration config = new Configuration._internal();

class Configuration {
  final Uri configUri = Uri.parse('');
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
