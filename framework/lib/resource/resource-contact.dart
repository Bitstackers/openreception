part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Contact {

  static String nameSpace = 'contact';

  static Uri single(Uri host, int ContactID) =>
      Uri.parse('${root(host)}/${ContactID}');

  static Uri root(Uri host) =>
      Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host) =>
      Uri.parse('${root(host)}');

  static Uri singleByReception(Uri host, int contactID, int receptionID)
    => Uri.parse('${root(host)}/${contactID}/reception/${receptionID}');

  static Uri listByReception(Uri host, int receptionID)
    => Uri.parse('${root(host)}/list/reception/${receptionID}');

  static Uri calendar(Uri host, int contactID, int receptionID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/calendar');

  static Uri calendarEvent(Uri host, int contactID, int receptionID, int eventID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/calendar/event/${eventID}');

  static Uri endpoints(Uri host, int contactID, int receptionID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/endpoints');

  static Uri phones(Uri host, int contactID, int receptionID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/phones}');
}
