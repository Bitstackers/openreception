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
void testModelPlayback() {
  group('Model.Playback', () {
    test('serializationDeserialization',
        ModelPlayback.serializationDeserialization);

    test('serialization', ModelPlayback.serialization);

    test('buildObject', ModelPlayback.buildObject);
    test('parse', ModelPlayback.parse);
  });
}

/**
 *
 */
abstract class ModelPlayback {
  /**
   *
   */
  static void serialization() {
    Model.Playback builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static void serializationDeserialization() {
    Model.Playback builtObject = buildObject();

    Model.Playback deserializedObject =
        Model.Playback.parse(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.filename, equals(deserializedObject.filename));
    expect(builtObject.note, equals(deserializedObject.note));
    expect(builtObject.wrapInLock, equals(deserializedObject.wrapInLock));
    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));
  }

  /**
   *
   */
  static Model.Playback buildObject() {
    final String filename = 'somefile.wav';
    final bool lock = false;
    final String note = 'Just a test';
    final Model.Playback builtObject =
        new Model.Playback(filename, wrapInLock: lock, note: note);

    expect(builtObject.filename, equals(filename));
    expect(builtObject.note, equals(note));
    expect(builtObject.wrapInLock, equals(lock));

    return builtObject;
  }

  /**
   *
   */
  static void parse() {
    final String filename = 'somefile.wav';
    final String note = 'Just a test';

    Model.Playback builtObject = Model.Playback.parse('playback $filename');

    expect(builtObject.filename, equals(filename));
    expect(builtObject.wrapInLock, isFalse);

    builtObject = Model.Playback.parse('playback locked $filename');

    expect(builtObject.filename, equals(filename));
    expect(builtObject.wrapInLock, isTrue);
    expect(builtObject.note, isEmpty);

    /// Adding lots of spaces.
    builtObject = Model.Playback.parse('   playback      locked     $filename');

    expect(builtObject.filename, equals(filename));
    expect(builtObject.wrapInLock, isTrue);
    expect(builtObject.note, isEmpty);

    builtObject = Model.Playback.parse('playback locked $filename ($note)');

    expect(builtObject.filename, equals(filename));
    expect(builtObject.wrapInLock, isTrue);
    expect(builtObject.note, equals(note));

    builtObject =
        Model.Playback.parse('  playback   locked   $filename   ($note)   ');

    expect(builtObject.filename, equals(filename));
    expect(builtObject.wrapInLock, isTrue);
    expect(builtObject.note, equals(note));

    ///TODO check exceptions.
    expect(() => Model.Playback.parse('layback locked $filename ($note) '),
        throwsA(new isInstanceOf<FormatException>()));
  }
}
