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

part of openreception.framework.test;

void _testModelNamedExtension() {
  group('Model.NamedExtension', () {
    test('deserialization', _ModelNamedExtension.deserialization);

    test('serialization', _ModelNamedExtension.serialization);

    test('buildObject', _ModelNamedExtension.buildObject);
  });
}

/**
*
 */
abstract class _ModelNamedExtension {
/**
 *
 */
  static void serialization() {
    model.NamedExtension builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

/**
 *
 */
  static void deserialization() {
    model.NamedExtension builtObject = buildObject();

    model.NamedExtension deserializedObject =
        model.NamedExtension.decode(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.name, equals(deserializedObject.name));

    expect(builtObject.actions, equals(builtObject.actions));
  }

/**
 *
 */
  static model.NamedExtension buildObject() {
    final name = 'extension-1';
    final List<model.Action> actions = [
      new model.Playback('filename.wav'),
      new model.Enqueue('queue-1')
    ];

    model.NamedExtension builtObject = new model.NamedExtension(name, actions);

    expect(builtObject.name, equals(name));
    expect(builtObject.actions, equals(actions));
    return builtObject;
  }
}
