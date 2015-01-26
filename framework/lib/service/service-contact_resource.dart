part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class ContactResource {

  static String nameSpace = 'contact';

  static Uri single(Uri host, int ContactID, {String token}) {
    Uri url = Uri.parse('${root(host)}/${ContactID}');
    return appendToken(url, token);
  }

  static Uri root(Uri host, {String token}) {
    Uri url = Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');
    return appendToken(url, token);
  }

  static Uri list(Uri host, {String token}) {
    Uri url = Uri.parse('${root(host)}');
    return appendToken(url, token);
  }
}
