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

testModelNamedExtension() {
  group('Model.NamedExtension', () {
    test('deserialization', ModelNamedExtension.deserialization);

    test('serialization', ModelNamedExtension.serialization);

    test('buildObject', ModelNamedExtension.buildObject);
  });
}

/**
*
 */
abstract class ModelNamedExtension {
/**
 *
 */
  static void serialization() {
    Model.NamedExtension builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

/**
 *
 */
  static void deserialization() {
    Model.NamedExtension builtObject = buildObject();

    Model.NamedExtension deserializedObject =
        Model.NamedExtension.decode(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.name, equals(deserializedObject.name));

    expect(builtObject.actions, equals(builtObject.actions));
  }

/**
 *
 */
  static Model.NamedExtension buildObject() {
    final name = 'extension-1';
    final List<Model.Action> actions = [
      new Model.Playback ('filename.wav'),
      new Model.Enqueue('queue-1')];



    Model.NamedExtension builtObject = new Model.NamedExtension(name, actions);

    expect(builtObject.name, equals(name));
    expect(builtObject.actions, equals(actions));
    return builtObject;
  }
}
