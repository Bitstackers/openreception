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

void testModelAction() {
  group('Model.Action', () {
    test('parseUndefined', ModelAction.parseUndefined);
    test('parseTransfer', ModelAction.parseTransfer);
    test('parseVoicemail', ModelAction.parseVoicemail);
    test('parseEnqueue', ModelAction.parseEnqueue);

    test('parseNotify', ModelAction.parseNotify);
    test('parseRingtone', ModelAction.parseRingtone);
    test('parsePlayback', ModelAction.parsePlayback);
    test('parseIvr', ModelAction.parseIvr);
  });
}

/**
 *
 */
abstract class ModelAction {
  /**
   *
   */
  static void parsePlayback() {
    final String file = 'sub_1';
    final String note = 'a note';

    Model.Playback builtObject = Model.Action.parse('playback $file ($note)');

    expect(builtObject.filename, equals(file));
    expect(builtObject.note, equals(note));
    expect(builtObject.wrapInLock, equals(false));
  }

  static void parseTransfer() {
    final String file = 'sub_1';
    final String note = 'a note';

    Model.Playback builtObject = Model.Action.parse('playback $file ($note)');

    expect(builtObject.filename, equals(file));
    expect(builtObject.note, equals(note));
    expect(builtObject.wrapInLock, equals(false));
  }

  static void parseVoicemail() {
    final String vmBox = 'box1';
    final String note = 'a note';
    final String recipient = 'someone@somewhere.org';

    Model.Voicemail builtObject =
        Model.Action.parse('voicemail $vmBox $recipient ($note)');

    expect(builtObject.vmBox, equals(vmBox));
    expect(builtObject.note, equals(note));
    expect(builtObject.recipient, equals(recipient));
  }

  static void parseEnqueue() {
    final String queue = 'box1';
    final String note = 'a note';
    final String music = 'nice_tunes';

    Model.Enqueue builtObject =
        Model.Action.parse('enqueue $queue music $music ($note)');

    expect(builtObject.queueName, equals(queue));
    expect(builtObject.note, equals(note));
    expect(builtObject.holdMusic, equals(music));
  }

  static void parseRingtone() {
    final int count = 3;

    Model.Ringtone builtObject =
        Model.Action.parse('ringtone $count');

    expect(builtObject.count, equals(count));
  }

  static void parseNotify() {
    final String target = 'receptionists';

    Model.Notify builtObject =
        Model.Action.parse('notify $target');

    expect(builtObject.eventName, equals(target));
  }

  static void parseIvr() {
    final String menu = 'ivr_1';
    final String note = 'a note';

    Model.Ivr builtObject =
        Model.Action.parse('ivr $menu ($note)');

    expect(builtObject.menuName, equals(menu));
    expect(builtObject.note, equals(note));
  }

  /**
   *
   */
  static void parseUndefined() {
    expect(() => Model.Action.parse('wrong wrong (just wrong)'),
        throwsA(new isInstanceOf<FormatException>()));
  }

}
