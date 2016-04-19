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


/**
 *
 */
void testModelNotify() {
  group('Model.Notify', () {
    test('serializationDeserialization',
        ModelNotify.serializationDeserialization);

    test('serialization', ModelNotify.serialization);

    test('buildObject', ModelNotify.buildObject);
    test('parse', ModelNotify.parse);
  });
}

/**
 *
 */
abstract class ModelNotify {
  /**
   *
   */
  static void serialization() {
    Model.Notify builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static void serializationDeserialization() {
    Model.Notify builtObject = buildObject();

    Model.Notify deserializedObject =
        Model.Notify.parse(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.eventName, equals(deserializedObject.eventName));
    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

  }

  /**
   *
   */
  static Model.Notify buildObject() {
    final String eventName = 'call-offer';
    final Model.Notify builtObject =
        new Model.Notify(eventName);

    expect(builtObject.eventName, equals(eventName));

    return builtObject;
  }

  /**
   *
   */
  static void parse() {
    final String eventName = 'call-offer';

    Model.Notify builtObject = Model.Notify.parse('notify $eventName');

    expect(builtObject.eventName, equals(eventName));

    /// Adding lots of spaces.
    builtObject = Model.Notify.parse('   notify     $eventName');

    expect(builtObject.eventName, equals(eventName));


    ///TODO check exceptions.
    expect(() => Model.Notify.parse('notif $eventName'),
        throwsA(new isInstanceOf<FormatException>()));
  }
}
