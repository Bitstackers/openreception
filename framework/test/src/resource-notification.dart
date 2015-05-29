part of openreception.test;

void testResourceNotification() {
  group('Resource.Notification', () {
    test('socket', ResourceNotification.notifications);
    test('socket (bad schema)', ResourceNotification.notificationsBadSchema);
    test('send', ResourceNotification.send);
    test('broadcast', ResourceNotification.broadcast);
  });
}

abstract class ResourceNotification {
  static final Uri notificationServer = Uri.parse('http://localhost:4242');
  static final Uri notificationSocket = Uri.parse('ws://localhost:4242');

  static void notifications() => expect(
      Resource.Notification.notifications(notificationSocket),
      equals(Uri.parse('${notificationSocket}/notifications')));

  static void notificationsBadSchema() => expect(
      () => Resource.Notification.notifications(notificationServer),
      throwsA(new isInstanceOf<ArgumentError>()));

  static void send() => expect(Resource.Notification.send(notificationServer),
      equals(Uri.parse('${notificationServer}/send')));

  static void broadcast() => expect(
      Resource.Notification.broadcast(notificationServer),
      equals(Uri.parse('${notificationServer}/broadcast')));
}
