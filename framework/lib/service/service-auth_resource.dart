part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class AuthResource {

  /// The intial component of the Uri.
  static String nameSpace = 'token';

  static Uri tokenToUser(Uri host, String token)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/${token}');
}

