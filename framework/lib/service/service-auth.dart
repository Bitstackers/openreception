part of openreception.service;

class Authentication {

  static final String className = '${libraryName}.Authentication';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';


  Authentication (Uri this._host, String this._token, this._backed);

  /**
   * Performs a lookup of the user on the notification server via the supplied token.
   */
  Future<Model.User> userOf(String token) =>
      this._backed.get (Resource.Authentication.tokenToUser(this._host, token))
      .then((String response)
        => new Model.User.fromMap(JSON.decode(response)));
}
