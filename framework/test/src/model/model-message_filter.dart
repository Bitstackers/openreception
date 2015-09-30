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

void testModelMessageFilter() {
  group('Model.MessageFilter', () {
    test('buildObject', ModelMessageFilter.buildObject);
    test('deserialization', ModelMessageFilter.deserialization);
    test('serialization', ModelMessageFilter.serialization);
    test('sqlFilter', ModelMessageFilter.sqlFilter);
  });
}

abstract class ModelMessageFilter {

  static void deserialization() {
    Model.MessageFilter obj = buildObject();
    Model.MessageFilter deserializedObj =
        new Model.MessageFilter.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.contactID, equals(deserializedObj.contactID));
    expect(obj.limitCount, equals(deserializedObj.limitCount));
    expect(obj.messageState, equals(deserializedObj.messageState));
    expect(obj.upperMessageID, equals(deserializedObj.upperMessageID));
    expect(obj.receptionID, equals(deserializedObj.receptionID));
    expect(obj.userID, equals(deserializedObj.userID));
  }

  static void serialization() {
    Model.MessageFilter builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object manually.
   */
  static Model.MessageFilter buildObject() {
    final int contactId = 1;
    final int limitCount = 100;
    final String messageState = Model.MessageState.validStates.first;
    final int receptionId = 2;
    final int upperMessageID = 4;
    final int userID = 99;

    Model.MessageFilter obj = new Model.MessageFilter.empty()
      ..contactID = contactId
      ..limitCount = limitCount
      ..messageState = messageState
      ..upperMessageID = upperMessageID
      ..receptionID = receptionId
      ..userID = userID;

    expect(obj.contactID, equals(contactId));
    expect(obj.limitCount, equals(limitCount));
    expect(obj.messageState, equals(messageState));
    expect(obj.upperMessageID, equals(upperMessageID));
    expect(obj.receptionID, equals(receptionId));
    expect(obj.userID, equals(userID));

    return obj;
  }

  /**
   * Test SQL filter
   */
  static sqlFilter() {
    final int contactId = 1;
    final int receptionId = 2;
    final int upperMessageID = 4;
    final int userID = 99;

    Model.MessageFilter obj = new Model.MessageFilter.empty()
      ..contactID = Model.Contact.noID
      ..messageState = ''
      ..upperMessageID = Model.Message.noID
      ..receptionID = Model.Reception.noID
      ..userID = Model.User.noID;

    expect(obj.asSQL, isEmpty);

    expect(obj.asSQL, isEmpty);

    obj.contactID = contactId;
    expect(obj.asSQL, equals('WHERE context_contact_id = $contactId'));
    obj.receptionID = receptionId;
    expect(obj.asSQL, equals('WHERE context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId'));
    obj.upperMessageID = upperMessageID;
    expect(obj.asSQL, equals('WHERE message.id <= $upperMessageID '
                             'AND context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId'));
    obj.userID = userID;
    expect(obj.asSQL, equals('WHERE message.id <= $upperMessageID '
                             'AND taken_by_agent = $userID '
                             'AND context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId'));

    obj.messageState = Model.MessageState.Sent;
    expect(obj.asSQL, equals('WHERE message.id <= $upperMessageID '
                             'AND taken_by_agent = $userID '
                             'AND context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId '
                             'AND sent'));

    obj.messageState = Model.MessageState.Pending;
    expect(obj.asSQL, equals('WHERE message.id <= $upperMessageID '
                             'AND taken_by_agent = $userID '
                             'AND context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId '
                             'AND enqueued'));

    obj.messageState = Model.MessageState.Saved;
    expect(obj.asSQL, equals('WHERE message.id <= $upperMessageID '
                             'AND taken_by_agent = $userID '
                             'AND context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId '
                             'AND (NOT enqueued AND NOT sent)'));
    obj.messageState = Model.MessageState.NotSaved;
    expect(obj.asSQL, equals('WHERE message.id <= $upperMessageID '
                             'AND taken_by_agent = $userID '
                             'AND context_reception_id = $receptionId '
                             'AND context_contact_id = $contactId '
                             'AND (enqueued OR sent)'));
  }
}
