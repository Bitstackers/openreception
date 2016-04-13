library management_tool.configuration;

import 'package:openreception_framework/model.dart' as model;

Configuration config = new Configuration._internal();

class Configuration {
  String _token = '';
  final Uri configUri = Uri.parse('http://10.10.1.118:9009');
  model.ClientConfiguration clientConfig =
      new model.ClientConfiguration.empty();

  model.User user = new model.User.empty();

  String get token => _token;
  void set token(String value) {
    _token = value;
  }

  Configuration._internal();
}
