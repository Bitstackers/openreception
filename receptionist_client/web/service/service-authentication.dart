part of service;

abstract class Authentication {

  static ORService.Authentication _store = null;

  static ORService.Authentication get store {
    if (_store == null) {
      _store = new ORService.Authentication
          (configuration.authBaseUrl,
           configuration.token,
           new ORServiceHTML.Client());
    }

    return _store;
  }
}
