part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Authentication {

  /// The intial component of the Uri.
  static String nameSpace = 'token';

  /**
   * Resource that returns the user currently associated with a token.
   * Has the format http:/<host>/token/<requestedToken>
   */
  static Uri tokenToUser(Uri host, String requestedToken)
    => Uri.parse('${Util.removeTailingSlashes(host)}'
                 '/${nameSpace}'
                 '/${requestedToken}');

  /**
   * Resource that checks if a is user currently associated with a token.
   * Has the format http:/<host>/token/<requestedToken>/validate
   */
  static Uri validate(Uri host, String requestedToken)
    => Uri.parse('${Util.removeTailingSlashes(host)}'
                 '/${nameSpace}'
                 '/${requestedToken}'
                 '/validate');

}

