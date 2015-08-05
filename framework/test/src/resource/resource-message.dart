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

void testResourceMessage() {
  group('Resource.Message', () {
    test('singleMessage', ResourceMessage.singleMessage);
    test('send', ResourceMessage.send);
    test('list', ResourceMessage.list);
  });
}

abstract class ResourceMessage {
  static Uri messageServer = Uri.parse('http://localhost:4040');

  static void singleMessage() => expect(
      Resource.Message.single(messageServer, 5),
      equals(Uri.parse('${messageServer}/message/5')));

  static void send() => expect(Resource.Message.send(messageServer, 5),
      equals(Uri.parse('${messageServer}/message/5/send')));

  static void list() => expect(Resource.Message.list(messageServer),
      equals(Uri.parse('${messageServer}/message/list')));
}
