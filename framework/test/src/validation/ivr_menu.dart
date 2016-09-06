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

void _ivrMenuTests() {
  final String filename = 'somefile.wav';

  final String note = 'Just a test';
  final model.Playback greeting = new model.Playback(filename, note: note);

  final List<model.IvrEntry> entries = <model.IvrEntry>[
    new model.IvrVoicemail(
        '1',
        new model.Voicemail('vm-corp_1',
            recipient: 'guy@corp1.org', note: 'Just some guy')),
    new model.IvrSubmenu('2', 'sub-1')
  ];

  group('validation.ivrMenu', () {
    test('menu with no name', () {
      final model.IvrMenu menu = new model.IvrMenu('', greeting)
        ..entries = entries;

      expect(validateIvrMenu(menu).length, equals(1));
    });

    test('menu with non-alphanumeric name', () {
      {
        // Name contains spaces.
        final model.IvrMenu menu = new model.IvrMenu('test 3', greeting)
          ..entries = entries;

        expect(validateIvrMenu(menu).length, equals(1));
      }

      {
        /// Name contains non-alphanumeric character.
        final model.IvrMenu menu = new model.IvrMenu('menü', greeting)
          ..entries = entries;

        expect(validateIvrMenu(menu).length, equals(1));
      }
    });

    test('menu with empty greeting', () {
      final model.IvrMenu menu = new model.IvrMenu('named', model.Playback.none)
        ..entries = entries;

      expect(validateIvrMenu(menu).length, equals(1));
    });

    test('menu with a bad submenu', () {
      final model.IvrMenu menu = new model.IvrMenu('named', greeting)
        ..entries = entries
        ..submenus = <model.IvrMenu>[
          new model.IvrMenu('', greeting)..entries = entries
        ];

      expect(validateIvrMenu(menu).length, equals(1));
    });

    test('bad menu with a bad submenu', () {
      final model.IvrMenu menu = new model.IvrMenu('named', model.Playback.none)
        ..entries = entries
        ..submenus = <model.IvrMenu>[
          new model.IvrMenu('', greeting)..entries = entries
        ];

      expect(validateIvrMenu(menu).length, equals(2));
    });
  });
}
