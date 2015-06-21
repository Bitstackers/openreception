part of openreception.test;

void testResourceNotification() {
  group('Resource.Notification', () {
    test('socket', ResourceNotification.notifications);
    test('socket (bad schema)', ResourceNotification.notificationsBadSchema);
    test('send', ResourceNotification.send);
    test('broadcast', ResourceNotification.broadcast);
    test('clientConnection', ResourceNotification.clientConnection);
    test('clientConnections', ResourceNotification.clientConnections);
  });
}

abstract class ResourceNotification {
  static final Uri _notificationService = Uri.parse('http://localhost:4242');
  static final Uri _notificationSocket = Uri.parse('ws://localhost:4242');

  static void notifications() => expect(
      Resource.Notification.notifications(_notificationSocket),
      equals(Uri.parse('${_notificationSocket}/notifications')));

  static void notificationsBadSchema() => expect(
      () => Resource.Notification.notifications(_notificationService),
      throwsA(new isInstanceOf<ArgumentError>()));

  static void send() => expect(Resource.Notification.send(_notificationService),
      equals(Uri.parse('${_notificationService}/send')));

  static void clientConnection() => expect(Resource.Notification.clientConnection(_notificationService, 123),
      equals(Uri.parse('${_notificationService}/connection/123')));

  static void clientConnections() => expect(Resource.Notification.clientConnections(_notificationService),
      equals(Uri.parse('${_notificationService}/connection')));

  static void broadcast() => expect(
      Resource.Notification.broadcast(_notificationService),
      equals(Uri.parse('${_notificationService}/broadcast')));
}
