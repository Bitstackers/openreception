part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resource Uri objects across servers and clients.
 */
abstract class ReceptionResource {

  static const String nameSpace = 'reception';
  static const String _calendar  = '/calendar';
  static const String _event     = '/event';

  static Uri single(Uri host, int receptionID)
    => Uri.parse('${root(host)}/${receptionID}');

  static Uri root(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host)
    => Uri.parse('${root(host)}/list');

  static Uri subset(Uri host, int upperReceptionID, int count) {
    throw new UnimplementedError('Currently unsupported!');

    return Uri.parse('${list(host)}/${upperReceptionID}/limit/${count}');
  }

  static Uri calendar(Uri host, int receptionID) =>
    Uri.parse('${root(host)}/${receptionID}/calendar');

  static Uri calendarEvent(Uri host, int receptionID, int eventID) =>
    Uri.parse('${root(host)}/${receptionID}/calendar/event/${eventID}');

}
