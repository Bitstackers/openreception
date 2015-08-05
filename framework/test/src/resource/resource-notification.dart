/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

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
