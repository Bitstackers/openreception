library configuration;

Configuration config = new Configuration._internal();

class Configuration {
  String _cdrUrl = 'http://localhost:4090';
  String _serverUrl = 'http://localhost:4100';
  String _token = 'feedabbadeadbeef0';
  String authBaseUrl = 'http://localhost:4050';

  String get cdrUrl => _cdrUrl;
  String get serverUrl => _serverUrl;
  String get token => _token;
  void set token(String value) {
    _token = value;
  }

  Configuration._internal();
}
