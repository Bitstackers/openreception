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

part of openreception.framework.test;

void testModelMessageEndpoint() {
  group('Model.MessageEndpoint', () {
    test('buildObject', ModelMessageEndpoint.buildObject);
    test('deserialization', ModelMessageEndpoint.deserialization);
    test('serialization', ModelMessageEndpoint.serialization);
  });
}

abstract class ModelMessageEndpoint {
  static void deserialization() {
    Model.MessageEndpoint obj = buildObject();
    Model.MessageEndpoint deserializedObj =
        new Model.MessageEndpoint.fromMap(JSON.decode(JSON.encode(obj)));

    expect(obj.role, equals(deserializedObj.role));
    expect(obj.address, equals(deserializedObj.address));
    expect(obj.name, equals(deserializedObj.name));
    expect(obj.type, equals(deserializedObj.type));
    expect(obj.note, equals(deserializedObj.note));
  }

  static void serialization() {
    Model.MessageEndpoint builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   * Build an object manually.
   */
  static Model.MessageEndpoint buildObject() {
    final String name = 'John Arbuckle';
    final String address = 'test@test.test';
    final String note = 'Some Reception';
    final String type = Model.MessageEndpointType.emailTo;

    Model.MessageEndpoint obj = new Model.MessageEndpoint.empty()
      ..address = address
      ..name = name
      ..note = note
      ..type = type;

    expect(obj.role, equals(Model.Role.TO));
    expect(obj.address, equals(address));
    expect(obj.name, equals(name));
    expect(obj.note, equals(note));
    expect(obj.type, equals(type));

    return obj;
  }
}
