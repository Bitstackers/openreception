part of openreception.service;

/**
 * Authentication service client.
 */
class Authentication {
  static final String className = '${libraryName}.Authentication';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   * Default constructor. Needs a host for backend uri, a user token and a
   * webclient for handling the transport.
   */
  Authentication(Uri this._host, String this._token, this._backend);

  /**
   * Performs a lookup of the user on the notification server from the
   * supplied token.
   */
  Future<Model.User> userOf(String token) {
    Uri uri = Resource.Authentication.tokenToUser(this._host, token);

    return this._backend.get(uri).then(
        (String response) => new Model.User.fromMap(JSON.decode(response)));
  }

  /**
   * Validate [token]. Throws [NotFound] exception if the token is not valid.
   */
  Future validate(String token) {
    Uri uri = Resource.Authentication.validate(this._host, token);

    return this._backend.get(uri);
  }
}
