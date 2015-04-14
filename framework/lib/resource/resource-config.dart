part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Config {

  static String nameSpace = 'configuration';

  static Uri get(Uri host) => root(host);

  static Uri root(Uri host) =>
      Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');
}
