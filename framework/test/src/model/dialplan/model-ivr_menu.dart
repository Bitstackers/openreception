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
void testModelIvrMenu() {
  group('Model.IvrMenu', () {
    test('serializationDeserialization',
        ModelIvrMenu.serializationDeserialization);

    test('serialization', ModelIvrMenu.serialization);

    test('buildObject', ModelIvrMenu.buildObject);
    test('validation', ModelIvrMenu.validation);
  });
}

/**
 *
 */
abstract class ModelIvrMenu {
  static Logger _log = new Logger('test.Model.IvrMenu');
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

    expect(builtObject.entries, equals(builtObject.entries));
  }

  /**
   *
   */
  static Model.IvrMenu buildObject() {
    final String name = 'ivr_1';
    final String sub1name = 'sub1';
    final String sub2name = 'sub2';
    final String filename = 'somefile.wav';
    final String sub1filename = 'sub1somefile.wav';
    final String sub2filename = 'sub2somefile.wav';

    final String note = 'Just a test';
    final Model.Playback greeting =
        new Model.Playback(filename, wrapInLock: false, note: note);

    final Model.Playback sub1greeting =
        new Model.Playback(sub1filename, wrapInLock: false, note: note);

    final Model.Playback sub2greeting =
        new Model.Playback(sub2filename, wrapInLock: false, note: note);

    final List<Model.IvrEntry> entries = [
      new Model.IvrVoicemail(
          '1',
          new Model.Voicemail('vm-corp_1',
              recipient: 'guy@corp1.org', note: 'Just some guy')),
      new Model.IvrSubmenu('2', 'sub-1')
    ];

    final List<Model.IvrEntry> sub1entries = [
      new Model.IvrVoicemail(
          '1',
          new Model.Voicemail('vm-corp_1',
              recipient: 'guy@corp1.org', note: 'Just some guy')),
      new Model.IvrSubmenu('2', 'sub-2'),
      new Model.IvrTopmenu('*')
    ];

    final List<Model.IvrEntry> sub2entries = [
      new Model.IvrVoicemail(
          '1',
          new Model.Voicemail('vm-corp_1',
              recipient: 'guy@corp1.org', note: 'Just some guy')),
      new Model.IvrSubmenu('2', 'sub-1')
    ];

    final Model.IvrMenu sub1 = new Model.IvrMenu(sub1name, sub1greeting)
      ..entries = sub1entries;
    final Model.IvrMenu sub2 = new Model.IvrMenu(sub2name, sub2greeting)
      ..entries = sub2entries;

    Model.IvrMenu builtObject = new Model.IvrMenu(name, greeting)
      ..entries = entries
      ..submenus = [sub1, sub2];

    expect(builtObject.name, equals(name));
    expect(builtObject.greetingShort.filename, equals(filename));
    expect(builtObject.greetingShort.note, equals(note));
    expect(builtObject.greetingShort.wrapInLock, isFalse);
    expect(builtObject.greetingShort.toJson(), equals(greeting.toJson()));

    expect(builtObject.greetingLong.filename, equals(filename));
    expect(builtObject.greetingLong.note, equals(note));
    expect(builtObject.greetingLong.wrapInLock, equals(isFalse));
    expect(builtObject.greetingLong.toJson(), equals(greeting.toJson()));

    return builtObject;
  }

  static void validation() {
    final String filename = 'somefile.wav';

    final String note = 'Just a test';
    final Model.Playback greeting =
        new Model.Playback(filename, wrapInLock: false, note: note);

    final List<Model.IvrEntry> entries = [
      new Model.IvrVoicemail(
          '1',
          new Model.Voicemail('vm-corp_1',
              recipient: 'guy@corp1.org', note: 'Just some guy')),
      new Model.IvrSubmenu('2', 'sub-1')
    ];

    _log.info('Building a menu with no name');
    Model.IvrMenu menu = new Model.IvrMenu('', greeting)..entries = entries;

    expect(Model.validateIvrMenu(menu).length, equals(1));

    _log.info('Building a menu with no enties');
    menu = new Model.IvrMenu('named', greeting)..entries = [];

    _log.info('Building a menu with no enties');
    expect(Model.validateIvrMenu(menu).length, equals(1));

    _log.info('Building a menu with an empty greeting');
    menu = new Model.IvrMenu('named', Model.Playback.none)..entries = entries;

    expect(Model.validateIvrMenu(menu).length, equals(1));

    _log.info('Building a menu with a bad submenu');
    menu = new Model.IvrMenu('named', greeting)
      ..entries = entries
      ..submenus = [new Model.IvrMenu('', greeting)..entries = entries];

    expect(Model.validateIvrMenu(menu).length, equals(1));

    _log.info('Building a bad menu with a bad submenu');
    menu = new Model.IvrMenu('named', Model.Playback.none)
      ..entries = entries
      ..submenus = [new Model.IvrMenu('', greeting)..entries = entries];

    expect(Model.validateIvrMenu(menu).length, equals(2));
  }
}
