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
void testModelIvrEntry() {
  group('Model.IvrEntry', () {

    test('parseUndefined', ModelIvrEntry.parseUndefined);
    test('parseSubmenu', ModelIvrEntry.parseSubmenu);
    test('parseTopmenu', ModelIvrEntry.parseTopmenu);
    test('parseIvrTransfer', ModelIvrEntry.parseIvrTransfer);
    test('parseIvrVoicemail', ModelIvrEntry.parseIvrVoicemail);

  });

}

/**
 *
 */
abstract class ModelIvrEntry {

  /**
   *
   */
  static void serialization() {
    Model.IvrMenu builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  /**
   *
   */
  static void serializationDeserialization() {
    Model.IvrMenu builtObject = buildObject();

    Model.IvrMenu deserializedObject =
        Model.IvrMenu.decode(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.greetingShort.filename,
        equals(deserializedObject.greetingShort.filename));
    expect(builtObject.greetingShort.note,
        equals(deserializedObject.greetingShort.note));
    expect(builtObject.greetingShort.wrapInLock,
        equals(deserializedObject.greetingShort.wrapInLock));
    expect(builtObject.greetingShort.toJson(),
        equals(deserializedObject.greetingShort.toJson()));

    expect(builtObject.greetingLong.filename,
        equals(deserializedObject.greetingLong.filename));
    expect(builtObject.greetingLong.note,
        equals(deserializedObject.greetingLong.note));
    expect(builtObject.greetingLong.wrapInLock,
        equals(deserializedObject.greetingLong.wrapInLock));
    expect(builtObject.greetingLong.toJson(),
        equals(deserializedObject.greetingLong.toJson()));

    expect(builtObject.toJson(), equals(deserializedObject.toJson()));

    expect(builtObject.entries, equals(deserializedObject.entries));
  }

  /**
   *
   */
  static Model.IvrMenu buildObject() {
    final String name = 'ivr_1';
    final String filename = 'somefile.wav';
    final bool lock = false;
    final String note = 'Just a test';
    final Model.Playback greeting =
        new Model.Playback(filename, wrapInLock: lock, note: note);

    Model.IvrMenu builtObject = new Model.IvrMenu(name, greeting);

    expect(builtObject.name, equals(name));
    expect(builtObject.greetingShort.filename,
        equals(filename));
    expect(builtObject.greetingShort.note,
        equals(note));
    expect(builtObject.greetingShort.wrapInLock,
        equals(lock));
    expect(builtObject.greetingShort.toJson(),
        equals(greeting.toJson()));

    expect(builtObject.greetingLong.filename,
        equals(filename));
    expect(builtObject.greetingLong.note,
        equals(note));
    expect(builtObject.greetingLong.wrapInLock,
        equals(lock));
    expect(builtObject.greetingLong.toJson(),
        equals(greeting.toJson()));

    return builtObject;
  }

  /**
   *
   */
  static void parseSubmenu() {
    final String submenu = 'sub_1';

    Model.IvrSubmenu builtObject = Model.IvrEntry.parse('1: submenu $submenu');

    expect (builtObject.digits, equals('1'));
    expect (builtObject, new isInstanceOf<Model.IvrSubmenu>());
    expect (builtObject.name, equals(submenu));
  }

  /**
   *
   */
  static void parseIvrTransfer() {
    final String extension = '33444222';

    Model.IvrTransfer builtObject = Model.IvrEntry.parse('2: transfer $extension');

    expect (builtObject.digits, equals('2'));
    expect (builtObject, new isInstanceOf<Model.IvrTransfer>());
    expect (builtObject.transfer.extension, equals(extension));
  }

  /**
   *
   */
  static void parseIvrVoicemail() {
    final String vmBox = 'vm-33444222';
    final String recipient = 'krc@awesome.me';
    final String note = 'Standard email';

    Model.IvrVoicemail builtObject =
        Model.IvrEntry.parse('3: voicemail $vmBox $recipient ($note)');

    expect (builtObject.digits, equals('3'));
    expect (builtObject, new isInstanceOf<Model.IvrVoicemail>());
    expect (builtObject.voicemail.vmBox, equals(vmBox));
    expect (builtObject.voicemail.recipient, equals(recipient));
    expect (builtObject.voicemail.note, equals(note));

    builtObject =
        Model.IvrEntry.parse('3:   voicemail   $vmBox   $recipient   ($note)');

    expect (builtObject.digits, equals('3'));
    expect (builtObject, new isInstanceOf<Model.IvrVoicemail>());
    expect (builtObject.voicemail.vmBox, equals(vmBox));
    expect (builtObject.voicemail.recipient, equals(recipient));
    expect (builtObject.voicemail.note, equals(note));

    builtObject =
        Model.IvrEntry.parse('3: voicemail $vmBox ($note)');

    expect (builtObject.digits, equals('3'));
    expect (builtObject, new isInstanceOf<Model.IvrVoicemail>());
    expect (builtObject.voicemail.vmBox, equals(vmBox));
    expect (builtObject.voicemail.recipient, isEmpty);
    expect (builtObject.voicemail.note, equals(note));
  }

  /**
   *
   */
  static void parseTopmenu() {

    Model.IvrTopmenu builtObject = Model.IvrEntry.parse('*: topmenu');

    expect (builtObject.digits, equals('*'));
    expect (builtObject, new isInstanceOf<Model.IvrEntry>());
  }

  /**
   *
   */
  static void parseUndefined() {
    final String filename = 'somefile.wav';
    //final String note = 'Just a test';

    expect(() => Model.IvrEntry.parse('1: wrong-wrong-wrong '),
        throwsA(new isInstanceOf<FormatException>()));

    ///Wrong digit length.
    expect(() => Model.IvrEntry.parse('12: $filename'),
        throwsA(new isInstanceOf<FormatException>()));
  }
}
