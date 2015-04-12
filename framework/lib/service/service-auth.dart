part of openreception.service;

class Authentication {

  static final String className = '${libraryName}.Authentication';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';


  Authentication (Uri this._host, String this._token, this._backed);

  /**
   * Performs a lookup of the user on the notification server from the
   * supplied token.
   */
  Future<Model.User> userOf(String token) {
    Uri uri = Resource.Authentication.tokenToUser(this._host, token);

    return this._backed.get (uri)
      .then((String response)
        => new Model.User.fromMap(JSON.decode(response)));
  }

  /**
   * Validate [token]. Throws [NotFound] exception if the token is not valid.
   */
  Future validate(String token) {
    Uri uri = Resource.Authentication.validate(this._host, token);

    return this._backed.get (uri);
  }

}
