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
void testModelReceptionDialplan() {
  group('Model.ReceptionDialplan', () {


   test('buildObject', ModelReceptionDialplan.buildObject);
   test('deserialization', ModelReceptionDialplan.deserialization);
   test('serialization', ModelReceptionDialplan.serialization);

//   test('buildObject (menu)', ModelReceptionDialplan.buildObjectMenu);
//   test('serialization (menu)', ModelReceptionDialplan.serializationMenu);
//   test('deserialization (menu)', ModelReceptionDialplan.deserializationMenu);

  });
}

/**
 *
 */
abstract class ModelReceptionDialplan {

  static void deserialization() {
    Model.ReceptionDialplan builtObject = buildObject();
    Model.ReceptionDialplan deserializedObject =
        Model.ReceptionDialplan.decode(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.id, equals(deserializedObject.id));
    expect(builtObject.note, equals(deserializedObject.note));
    expect(builtObject.extension, equals(deserializedObject.extension));
    expect(builtObject.active, equals(deserializedObject.active));
    expect(builtObject.open, equals(deserializedObject.open));
    expect(builtObject.defaultActions, equals(deserializedObject.defaultActions));

  }

  /**
   *
   */
  static void serialization() {
    Model.ReceptionDialplan builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static Model.ReceptionDialplan buildObject() {
    final int id = 2;
    final bool active = false;
    final String extension = '12345678';
    final String note = 'Just a test reception dialplan';

    final List<Model.HourAction> open = [
      new Model.HourAction()
      ..extension = extension
      ..hours = Model.parseMultipleHours('mon-fri 16-17').toList()
      ..actions = [
        new Model.Playback ('somefile')
        ]
      ];

    final List<Model.Action> closed = [
        new Model.Playback ('otherfile')
      ];


    final Model.ReceptionDialplan builtObject =
        new Model.ReceptionDialplan()
    ..id = id
    ..active = active
    ..note = note
    ..open = open
    ..defaultActions = closed;

    expect(builtObject.id, equals(id));
    expect(builtObject.extension, equals(extension));
    expect(builtObject.note, equals(note));
    expect(builtObject.active, equals(active));
    expect(builtObject.open, equals(open));
    expect(builtObject.defaultActions, equals(closed));

    return builtObject;
  }
}
