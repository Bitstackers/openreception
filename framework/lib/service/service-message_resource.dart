part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class MessageResource {

  static String nameSpace = 'message';

  static String _removeTailingSlashes (Uri host) {
     String _trimmedHostname = host.toString();

     while (_trimmedHostname.endsWith('/')) {
       _trimmedHostname = _trimmedHostname.substring(0, _trimmedHostname.length-1);
     }

     return _trimmedHostname;
  }

  static Uri single(Uri host, int messageID)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/${messageID}');

  static Uri root(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/list');

  static Uri subset(Uri host, int upperMessageID, int count)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/list/${upperMessageID}/limit/${count}');
}
