part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Message {

  static String nameSpace = 'message';

  static Uri single(Uri host, int messageID)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}/${messageID}');

  static Uri send(Uri host, int messageID)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}/${messageID != Model.Message.noID ? '${messageID}/' : ''}send');

  static Uri root(Uri host)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host, {int limit: 100, Model.MessageFilter filter : null}) {
    return subset(host, 0, limit, filter : filter);
  }

  static Uri subset(Uri host, int upperMessageID, int count, {Model.MessageFilter filter : null}) {
    String filterParameter = filter!=null
                                     ? '?filter=${JSON.encode(filter)}'
                                     : '';

    return Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}/list/${upperMessageID}/limit/${count}${filterParameter}');
  }
}
