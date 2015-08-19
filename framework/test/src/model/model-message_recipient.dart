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

void testModelMessageRecipient() {
  group('Model.MessageRecipient', () {
    test('buildObject', ModelMessageRecipient.buildObject);
    test('deserialization', ModelMessageRecipient.deserialization);
    test('serialization', ModelMessageRecipient.serialization);
  });
}

abstract class ModelMessageRecipient {

  static void deserialization() {
    Model.MessageRecipient obj = buildObject();
    Model.MessageRecipient deserializedObj =
        new Model.MessageRecipient.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.role, equals(deserializedObj.role));
    expect(obj.address, equals(deserializedObj.address));
    expect(obj.name, equals(deserializedObj.name));
    expect(obj.type, equals(deserializedObj.type));

  }

  static void serialization() {
    Model.MessageRecipient builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object manually.
   */
  static Model.MessageRecipient buildObject() {
    final String role = Model.Role.RECIPIENT_ROLES.first;
    final String name = 'John Arbuckle';
    final String address = 'Test address';
    final String type = Model.MessageEndpointType.types.first;

    Model.MessageRecipient obj = new Model.MessageRecipient.empty()
      ..role = role
      ..address = address
      ..name = name
      ..type = type;

    expect(obj.role, equals(role));
    expect(obj.address, equals(address));
    expect(obj.name, equals(name));
    expect(obj.type, equals(type));

    return obj;
  }
}
