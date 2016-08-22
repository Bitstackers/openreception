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

part of openreception.framework.test;

void _testDialplanTools() {
  group('DialplanTools ReceptionDialplan xml validity', () {
    test('empty', _DialplanToolsReceptionDialplan.empty);
    test('openActions', _DialplanToolsReceptionDialplan.openActions);
    test('closedActions', _DialplanToolsReceptionDialplan.closedActions);
    test('bigDialplan', _DialplanToolsReceptionDialplan.bigDialplan);
  });

  group('DialplanTools IvrMenu xml validity', () {
    test('empty', _DialplanToolsIvrMenu.empty);
    test('openActions', _DialplanToolsIvrMenu.oneLevel);
    test('closedActions', _DialplanToolsIvrMenu.twoLevel);
  });
}

class _DialplanToolsReceptionDialplan {
  /**
   *
   */
  static void empty() {
    model.ReceptionDialplan rdp = new model.ReceptionDialplan();

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new model.Reception.empty()..name = 'ost'));
  }

  /**
   *
   */
  static void openActions() {
    model.ReceptionDialplan rdp = new model.ReceptionDialplan()
      ..active = true
      ..open = [
        new model.HourAction()
          ..hours = model.parseMultipleHours('mon-fri 8-17, sat 10-12').toList()
          ..actions = [new model.Playback('none')],
        new model.HourAction()
          ..hours = model.parseMultipleHours('sun 8-17').toList()
          ..actions = [
            new model.Notify('call-offer'),
            new model.Playback('none')
          ]
      ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new model.Reception.empty()..name = 'ost'));
  }

  /**
   *
   */
  static void closedActions() {
    model.ReceptionDialplan rdp = new model.ReceptionDialplan()
      ..active = true
      ..defaultActions = [new model.Playback('closed')];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .dialplanToXml(rdp, new model.Reception.empty()..name = 'ost'));
  }

  /**
   *
   */
  static void bigDialplan() {
    model.ReceptionDialplan rdp = new model.ReceptionDialplan()
      ..active = true
      ..open = [
        new model.HourAction()
          ..hours = model.parseMultipleHours('mon-wed 8-17, thur 10-17, fri 10-16:30')
              .toList()
          ..actions = [
            new model.Notify('call-offer'),
            new model.Ringtone(2),
            new model.Playback('greeting'),
            new model.Playback('2nd-greeting'),
            new model.Enqueue('pending',
                holdMusic: 'default', note: 'wait queue')
          ],
        new model.HourAction()
          ..hours = model.parseMultipleHours('sun 8-17').toList()
          ..actions = [
            new model.Playback('none', note: 'IVR transfer'),
            new model.Ivr('magic-ivr', note: 'Magic IVR menu')
          ]
      ]
      ..defaultActions = [
        new model.Playback('closed', note: 'Just closed'),
        new model.Voicemail('some-voicemail')
      ];

    final String xmlDialplan =
        new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
            .dialplanToXml(rdp, new model.Reception.empty()..name = 'ost');

    xml.parse(xmlDialplan);
  }
}

class _DialplanToolsIvrMenu {
  /**
   *
   */
  static void empty() {
    model.IvrMenu menu =
        new model.IvrMenu('some menu', new model.Playback('greeting'));

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .ivrToXml(menu));
  }

  /**
   *
   */
  static void oneLevel() {
    model.IvrMenu menu =
        new model.IvrMenu('some menu', new model.Playback('greeting'))
          ..entries = [
            new model.IvrVoicemail(
                '1',
                new model.Voicemail('testbox',
                    recipient: 'someone@somewhere', note: 'A mailbox')),
            new model.IvrTransfer(
                '2', new model.Transfer('1234444', note: 'A dude'))
          ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .ivrToXml(menu));
  }

  /**
   *
   */
  static void twoLevel() {
    model.IvrMenu menu =
        new model.IvrMenu('some-menu', new model.Playback('greeting'))
          ..entries = [
            new model.IvrVoicemail(
                '1',
                new model.Voicemail('testbox',
                    recipient: 'someone@somewhere', note: 'A mailbox')),
            new model.IvrSubmenu('2', 'some-submenu')
          ]
          ..submenus = [
            new model.IvrMenu('some-submenu', new model.Playback('greeting'))
              ..entries = [
                new model.IvrVoicemail(
                    '1',
                    new model.Voicemail('testbox2',
                        recipient: 'someone2@somewhere',
                        note: 'Another mailbox')),
                new model.IvrTransfer(
                    '2', new model.Transfer('1234442', note: 'Another dude')),
                new model.IvrTopmenu('*')
              ]
          ];

    xml.parse(new dpTools.DialplanCompiler(new dpTools.DialplanCompilerOpts())
        .ivrToXml(menu));
  }
}
