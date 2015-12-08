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
  group('DialplanTools xml validity', () {
    test('empty', DialplanTools.empty);
    test('openActions', DialplanTools.openActions);
    test('closedActions', DialplanTools.closedActions);
    test('bigDialplan', DialplanTools.bigDialplan);
  });
}

class DialplanTools {
  /**
   *
   */
  static void empty() {
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan();

    xml.parse(dpTools.convertTextual(rdp, 4));
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

    xml.parse(dpTools.convertTextual(rdp, 4));
  }

  /**
   *
   */
  static void closedActions() {
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan()
      ..active = true
      ..defaultActions = [new Model.Playback('closed', wrapInLock: false)];

    xml.parse(dpTools.convertTextual(rdp, 4));
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
            new Model.Enqueue('pending',
                holdMusic: 'standard', note: 'wait queue')
          ],
        new Model.HourAction()
          ..hours = Model.parseMultipleHours('sun 8-17').toList()
          ..actions = [
            new Model.Playback('none', wrapInLock: false, note: 'IVR transfer'),
            new Model.Ivr('magic-ivr', note: 'Magic IVR menu')
          ]
      ];

    xml.parse(dpTools.convertTextual(rdp, 4));
  }
}
