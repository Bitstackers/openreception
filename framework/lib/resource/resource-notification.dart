part of openreception.resource;

abstract class Notification {

  static Uri notifications(Uri host) {
    if (!['ws', 'wss'].contains(host.scheme)) {
      throw new ArgumentError.value(host.scheme, 'Resource.Notification', 'expected "ws" or "wss" scheme');
    }

    return Uri.parse('${host}/notifications');
  }

  static Uri send(Uri host)
      => Uri.parse('${host}/send');

  static Uri broadcast(Uri host)
      => Uri.parse('${host}/broadcast');
  
  static Uri clientConnections(Uri host)
      => Uri.parse('${host}/connection');
  
  static Uri clientConnection(Uri host, int uid)
      => Uri.parse('${host}/connection/${uid}');
}