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

void testModelMessageQueueEntry() {
  group('Model.MessageQueueEntry', () {
    test('buildObject', ModelMessageQueueEntry.buildObject);
    test('deserialization', ModelMessageQueueEntry.deserialization);
    test('serialization', ModelMessageQueueEntry.serialization);

    test('handleRecipient', ModelMessageQueueEntry.handleRecipient);
  });
}

abstract class ModelMessageQueueEntry {
  static void handleRecipient() {
    Model.MessageQueueItem obj = buildObject();

    final int origLen = obj.unhandledRecipients.length;
    expect(origLen, greaterThan(1));
    expect(obj.handledRecipients, isEmpty);

    Model.MessageRecipient handled = obj.unhandledRecipients.first;

    obj.handledRecipients = [handled];

    expect(obj.unhandledRecipients.length, equals(origLen - 1));
    expect(obj.handledRecipients.length, equals(1));

    expect(obj.unhandledRecipients.contains(handled), isFalse);
    expect(obj.handledRecipients.contains(handled), isTrue);
  }

  static void deserialization() {
    Model.MessageQueueItem obj = buildObject();
    Model.MessageQueueItem deserializedObj =
        new Model.MessageQueueItem.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.id, equals(deserializedObj.id));

    expect(obj.message.toJson(), equals(deserializedObj.message.toJson()));

    expect(
        obj.unhandledRecipients, equals(deserializedObj.unhandledRecipients));
  }

  static void serialization() {
    Model.MessageQueueItem builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object manually.
   */
  static Model.MessageQueueItem buildObject() {
    final id = 666;
    final lastTry = new DateTime.now();
    final message = ModelMessage.buildObject();

    final List<Model.MessageRecipient> recipients = [
      new Model.MessageRecipient.empty()
        ..address = 'neverland'
        ..contactName = 'Unholy one'
        ..receptionName = 'A hot place'
        ..role = Model.Role.TO
        ..type = 'email',
      new Model.MessageRecipient.empty()
        ..address = 'neverland 2'
        ..contactName = 'Unholy one jr.'
        ..receptionName = 'A less hot place'
        ..role = Model.Role.CC
        ..type = 'email',
    ];

    Model.MessageQueueItem obj = new Model.MessageQueueItem.empty()
      ..id = id
      ..message = message
      ..unhandledRecipients = recipients;

    expect(obj.id, equals(id));

    expect(obj.message.toJson(), equals(message.toJson()));

    expect(obj.unhandledRecipients, equals(recipients));

    return obj;
  }
}
