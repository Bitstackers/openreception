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

testModelBaseContact() {
  group('Model.BaseContact', () {
    test('serializationDeserialization',
        ModelBaseContact.serializationDeserialization);

    test('serialization', ModelBaseContact.serialization);

    test('buildObject', ModelBaseContact.buildObject);
  });
}

abstract class ModelBaseContact {
  static void serialization() {
    Model.BaseContact builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static void serializationDeserialization() {
    Model.BaseContact builtObject = buildObject();
    Model.BaseContact deserializedObject =
        new Model.BaseContact.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.id, equals(deserializedObject.id));
    expect(builtObject.enabled, equals(deserializedObject.enabled));
    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.type, equals(deserializedObject.type));
  }

  static Model.BaseContact buildObject() {
    final int id = 21;
    final bool enabled = true;
    final String fullName = 'Biff, the goldfish';
    final String contactType = Model.ContactType.human;

    Model.BaseContact builtObject = new Model.BaseContact.empty()
      ..id = id
      ..enabled = enabled
      ..name = fullName
      ..type = contactType;

    expect(builtObject.id, equals(id));
    expect(builtObject.enabled, equals(enabled));
    expect(builtObject.name, equals(fullName));
    expect(builtObject.type, equals(contactType));

    return builtObject;
  }
}
