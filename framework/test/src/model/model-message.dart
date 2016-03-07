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

void testModelMessage() {
  group('Model.Message', () {
    test('deserialization', ModelMessage.deserialization);
    test('serialization', ModelMessage.serialization);
    test('buildObject', ModelMessage.buildObject);
    test('messageFlag', ModelMessage.messageFlag);
  });
}

abstract class ModelMessage {
  static void deserialization() {
    Model.Message obj = buildObject();
    Model.Message deserializedObj =
        new Model.Message.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.body, equals(deserializedObj.body));
    expect(obj.callerInfo.asMap, equals(deserializedObj.callerInfo.asMap));
    expect(obj.callId, equals(deserializedObj.callId));

    expect(obj.createdAt.difference(deserializedObj.createdAt).abs(),
        lessThan(new Duration(seconds: 1)));

    expect(obj.flag.called, equals(deserializedObj.flag.called));
    expect(
        obj.flag.manuallyClosed, equals(deserializedObj.flag.manuallyClosed));
    expect(obj.flag.pleaseCall, equals(deserializedObj.flag.pleaseCall));
    expect(obj.flag.urgent, equals(deserializedObj.flag.urgent));
    expect(obj.flag.willCallBack, equals(deserializedObj.flag.willCallBack));
    expect(obj.id, equals(deserializedObj.id));
    expect(obj.context.toJson(), equals(deserializedObj.context.toJson()));
    expect(
        obj.recipients.toList(), equals(deserializedObj.recipients.toList()));
    expect(obj.sender.id, equals(deserializedObj.sender.id));

    expect(obj.asMap, equals(deserializedObj.asMap));
  }

  static void serialization() {
    Model.Message builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object, and check that the expected values are present.
   */
  static Model.Message buildObject() {
    final Model.CallerInfo info = new Model.CallerInfo.empty()
      ..cellPhone = 'Drowned'
      ..company = 'Shifty eyes inc.'
      ..localExtension = 'Just ask for Bob'
      ..name = 'Ian Malcom'
      ..phone = 'Out of order';

    final Model.User sender = ModelUser.buildObject();
    final String callId = 'bad-ass-call';

    Set<Model.MessageEndpoint> rlist = new Set<Model.MessageEndpoint>()
      ..addAll([
        new Model.MessageEndpoint.empty()
          ..address = 'somewhere'
          ..name = 'someone'
          ..note = 'The Office'
          ..type = Model.MessageEndpointType.types.first
      ]);

    final messageBody = 'You should really clean up.';
    final createdAt = new DateTime.now();
    final id = 42;

    final Model.MessageContext context = new Model.MessageContext.empty()
      ..cid = 2
      ..contactName = 'John Doe'
      ..rid = 4
      ..receptionName = 'Nowhere';

    final Model.Message obj = new Model.Message.empty()
      ..body = messageBody
      ..callId = callId
      ..callerInfo = info
      ..createdAt = createdAt
      ..flag.called = true
      ..flag.manuallyClosed = true
      ..flag.pleaseCall = true
      ..flag.urgent = true
      ..flag.willCallBack = true
      ..id = id
      ..context = context
      ..recipients = rlist
      ..sender = sender;

    expect(obj.body, equals(messageBody));
    expect(obj.callerInfo.toJson(), equals(info.toJson()));
    expect(obj.callId, equals(callId));
    expect(obj.createdAt, equals(createdAt));
    expect(obj.flag.called, isTrue);
    expect(obj.flag.manuallyClosed, isTrue);
    expect(obj.flag.pleaseCall, isTrue);
    expect(obj.flag.urgent, isTrue);
    expect(obj.flag.willCallBack, isTrue);
    expect(obj.id, equals(id));
    expect(obj.context.toJson(), equals(context.toJson()));
    expect(obj.recipients.toList(), equals(rlist.toList()));
    expect(obj.sender.toJson(), equals(sender.toJson()));

    return obj;
  }

  static void messageFlag() {
    Model.Message builtObject = buildObject();

    builtObject.flag = new Model.MessageFlag.empty();

    expect(builtObject.manuallyClosed, equals(false));

    builtObject.flag.manuallyClosed = true;
    expect(builtObject.manuallyClosed, equals(true));
    builtObject.flag.manuallyClosed = false;
    expect(builtObject.manuallyClosed, equals(false));

    builtObject.flag = new Model.MessageFlag.empty();

    builtObject.manuallyClosed = true;
    expect(builtObject.manuallyClosed, equals(true));
    builtObject.manuallyClosed = false;
    expect(builtObject.manuallyClosed, equals(false));
  }
}
