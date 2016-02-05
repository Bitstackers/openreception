library configuration;

import 'package:openreception_framework/model.dart' as model;

Configuration config = new Configuration._internal();

class Configuration {
  String _token = '';
  final Uri configUri = Uri.parse('http://localhost:4080');
  model.ClientConfiguration clientConfig =
      new model.ClientConfiguration.empty();

  Uri userURI = Uri.parse('http://localhost:4030');
  model.User user = new model.User.empty();

  String get token => _token;
  void set token(String value) {
    _token = value;
  }

  Configuration._internal();
}
