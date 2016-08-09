/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.framework.test.validation;

void ivrMenuTests() {
  final String filename = 'somefile.wav';

  final String note = 'Just a test';
  final Model.Playback greeting = new Model.Playback(filename, note: note);

  final List<Model.IvrEntry> entries = [
    new Model.IvrVoicemail(
        '1',
        new Model.Voicemail('vm-corp_1',
            recipient: 'guy@corp1.org', note: 'Just some guy')),
    new Model.IvrSubmenu('2', 'sub-1')
  ];

  group('validation.ivrMenu', () {
    test('menu with no name', () {
      final Model.IvrMenu menu = new Model.IvrMenu('', greeting)
        ..entries = entries;

      expect(validateIvrMenu(menu).length, equals(1));
    });

    test('menu with non-alphanumeric name', () {
      {
        // Name contains spaces.
        final Model.IvrMenu menu = new Model.IvrMenu('test 3', greeting)
          ..entries = entries;

        expect(validateIvrMenu(menu).length, equals(1));
      }

      {
        /// Name contains non-alphanumeric character.
        final Model.IvrMenu menu = new Model.IvrMenu('menü', greeting)
          ..entries = entries;

        expect(validateIvrMenu(menu).length, equals(1));
      }
    });

    test('menu with empty greeting', () {
      final Model.IvrMenu menu = new Model.IvrMenu('named', Model.Playback.none)
        ..entries = entries;

      expect(validateIvrMenu(menu).length, equals(1));
    });

    test('menu with a bad submenu', () {
      final Model.IvrMenu menu = new Model.IvrMenu('named', greeting)
        ..entries = entries
        ..submenus = [new Model.IvrMenu('', greeting)..entries = entries];

      expect(validateIvrMenu(menu).length, equals(1));
    });

    test('bad menu with a bad submenu', () {
      final Model.IvrMenu menu = new Model.IvrMenu('named', Model.Playback.none)
        ..entries = entries
        ..submenus = [new Model.IvrMenu('', greeting)..entries = entries];

      expect(validateIvrMenu(menu).length, equals(2));
    });
  });
}
