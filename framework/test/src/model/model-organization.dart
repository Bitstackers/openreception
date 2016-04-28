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

void testModelOrganization() {
  group('Model.Organization', () {
    test('buildObject', ModelOrganization.buildObject);
    test('serialization', ModelOrganization.serialization);
    test('deserialization', ModelOrganization.deserialization);
  });
}

abstract class ModelOrganization {
  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() {
    Model.Organization builtObject = buildObject();

    expect(() => JSON.encode(builtObject), returnsNormally);
  }

  /**
   * Merely asserts that no exceptions arise.
   */
  static void deserialization() {
    Model.Organization builtObject = buildObject();

    String serializedObject = JSON.encode(builtObject);
    Model.Organization decodedObject =
        new Model.Organization.fromMap(JSON.decode(serializedObject));

    expect(builtObject.notes, equals(decodedObject.notes));
    expect(builtObject.id, equals(decodedObject.id));
    expect(builtObject.name, equals(decodedObject.name));

    expect(builtObject.toJson(), equals(decodedObject.toJson()));
  }

  static Model.Organization buildObject() {
    final List<String> notes = ['Goldmember'];
    final int id = 42;
    final String name = 'Hey Goldmember!';

    Model.Organization testOrganization = new Model.Organization.empty()
      ..notes = notes
      ..id = id
      ..name = name;
    expect(testOrganization.notes, equals(notes));
    expect(testOrganization.id, equals(id));
    expect(testOrganization.name, equals(name));

    return testOrganization;
  }
}
