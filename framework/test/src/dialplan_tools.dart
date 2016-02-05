/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

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

void testDialplanTools() {
  group('DialplanTools ReceptionDialplan xml validity', () {
    test('empty', DialplanToolsReceptionDialplan.empty);
    test('openActions', DialplanToolsReceptionDialplan.openActions);
    test('closedActions', DialplanToolsReceptionDialplan.closedActions);
    test('bigDialplan', DialplanToolsReceptionDialplan.bigDialplan);
  });

  group('DialplanTools IvrMenu xml validity', () {
    test('empty', DialplanToolsIvrMenu.empty);
    test('openActions', DialplanToolsIvrMenu.oneLevel);
    test('closedActions', DialplanToolsIvrMenu.twoLevel);
  });
}

class DialplanToolsReceptionDialplan {
  /**
   *
   */
  static void empty() {
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan();

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new Model.Reception.empty()..fullName = 'ost'));
  }

  /**
   *
   */
  static void openActions() {
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan()
      ..active = true
      ..open = [
        new Model.HourAction()
          ..hours = Model.parseMultipleHours('mon-fri 8-17, sat 10-12').toList()
          ..actions = [new Model.Playback('none')],
        new Model.HourAction()
          ..hours = Model.parseMultipleHours('sun 8-17').toList()
          ..actions = [
            new Model.Notify('call-offer'),
            new Model.Playback('none')
          ]
      ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new Model.Reception.empty()..fullName = 'ost'));
  }

  /**
   *
   */
  static void closedActions() {
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan()
      ..active = true
      ..defaultActions = [new Model.Playback('closed', wrapInLock: false)];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new Model.Reception.empty()..fullName = 'ost'));
  }

  /**
   *
   */
  static void bigDialplan() {
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan()
      ..active = true
      ..open = [
        new Model.HourAction()
          ..hours = Model
              .parseMultipleHours('mon-wed 8-17, thur 10-17, fri 10-16:30')
              .toList()
          ..actions = [
            new Model.Notify('call-offer'),
            new Model.Ringtone(2),
            new Model.Playback('greeting'),
            new Model.Playback('2nd-greeting'),
            new Model.Enqueue('pending',
                holdMusic: 'default', note: 'wait queue')
          ],
        new Model.HourAction()
          ..hours = Model.parseMultipleHours('sun 8-17').toList()
          ..actions = [
            new Model.Playback('none', wrapInLock: false, note: 'IVR transfer'),
            new Model.Ivr('magic-ivr', note: 'Magic IVR menu')
          ]
      ]
      ..defaultActions = [
        new Model.Playback('closed', wrapInLock: true, note: 'Just closed'),
        new Model.Voicemail('some-voicemail')
      ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new Model.Reception.empty()..fullName = 'ost'));
  }
}

class DialplanToolsIvrMenu {
  /**
   *
   */
  static void empty() {
    Model.IvrMenu menu =
        new Model.IvrMenu('some menu', new Model.Playback('greeting'));

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .ivrToXml(menu));
  }

  /**
   *
   */
  static void oneLevel() {
    Model.IvrMenu menu =
        new Model.IvrMenu('some menu', new Model.Playback('greeting'))
          ..entries = [
            new Model.IvrVoicemail(
                '1',
                new Model.Voicemail('testbox',
                    recipient: 'someone@somewhere', note: 'A mailbox')),
            new Model.IvrTransfer(
                '2', new Model.Transfer('1234444', note: 'A dude'))
          ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .ivrToXml(menu));
  }

  /**
   *
   */
  static void twoLevel() {
    Model.IvrMenu menu =
        new Model.IvrMenu('some-menu', new Model.Playback('greeting'))
          ..entries = [
            new Model.IvrVoicemail(
                '1',
                new Model.Voicemail('testbox',
                    recipient: 'someone@somewhere', note: 'A mailbox')),
            new Model.IvrSubmenu('2', 'some-submenu')
          ]
          ..submenus = [
            new Model.IvrMenu('some-submenu', new Model.Playback('greeting'))
              ..entries = [
                new Model.IvrVoicemail(
                    '1',
                    new Model.Voicemail('testbox2',
                        recipient: 'someone2@somewhere',
                        note: 'Another mailbox')),
                new Model.IvrTransfer(
                    '2', new Model.Transfer('1234442', note: 'Another dude')),
                new Model.IvrTopmenu('*')
              ]
          ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .ivrToXml(menu));
  }
}
