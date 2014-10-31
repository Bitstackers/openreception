part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class ReceptionResource {

  static String nameSpace = 'reception';

  static Uri single(Uri host, int receptionID)
    => Uri.parse('${root(host)}/${receptionID}');

  static Uri root(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host)
    => Uri.parse('${root(host)}/list');

  static Uri subset(Uri host, int upperReceptionID, int count)
    => Uri.parse('${list(host)}/${upperReceptionID}/limit/${count}');
}
