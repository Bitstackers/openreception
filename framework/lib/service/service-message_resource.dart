part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class MessageResource {

  static String nameSpace = 'message';

  static Uri single(Uri host, int messageID)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/${messageID}');

  static Uri send(Uri host, int messageID)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/${messageID != Model.Message.noID ? '${messageID}/' : ''}send');

  static Uri root(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/list');

  static Uri subset(Uri host, int upperMessageID, int count)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/list/${upperMessageID}/limit/${count}');
}
