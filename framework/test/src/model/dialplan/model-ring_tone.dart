/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

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

testModelRingtone() {
  group('Model.Ringtone', () {
    test('serializationDeserialization', ModelRingtone.deserialization);

    test('serialization', ModelRingtone.serialization);

    test('buildObject', ModelRingtone.buildObject);
  });
}

/**
*
 */
abstract class ModelRingtone {
/**
 *
 */
  static void serialization() {
    Model.Ringtone builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

/**
 *
 */
  static void deserialization() {
    Model.Ringtone builtObject = buildObject();

    Model.Ringtone deserializedObject =
        Model.Ringtone.parse(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.count, equals(deserializedObject.count));
  }

/**
 *
 */
  static Model.Ringtone buildObject() {
    final int count = 2;

    final Model.Ringtone builtObject = new Model.Ringtone(count);


    expect(builtObject.count, equals(count));

    return builtObject;
  }
}
