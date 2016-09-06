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

void _testResourceCallFlowControl() {
  group('Resource.CallFlowControl', () {
    test('stateReload', _ResourceCallFlowControl.stateReload);
    test('channelList', _ResourceCallFlowControl.channelList);
    test('peerList', _ResourceCallFlowControl.peerList);
    test('single', _ResourceCallFlowControl.single);
    test('pickup', _ResourceCallFlowControl.pickup);
    test('originate', _ResourceCallFlowControl.originate);
    test('park', _ResourceCallFlowControl.park);
    test('hangup', _ResourceCallFlowControl.hangup);
    test('transfer', _ResourceCallFlowControl.transfer);
    test('list', _ResourceCallFlowControl.list);

    test('activeRecordings', _ResourceCallFlowControl.activeRecordings);
    test('activeRecording', _ResourceCallFlowControl.activeRecording);
    test('agentStatistics', _ResourceCallFlowControl.agentStatistics);
    test('agentStatistic', _ResourceCallFlowControl.agentStatistic);
  });
}

abstract class _ResourceCallFlowControl {
  static Uri callFlowControlUri = Uri.parse('http://localhost:4242');

  static void activeRecordings() => expect(
      resource.CallFlowControl.activeRecordings(callFlowControlUri),
      equals(Uri.parse('$callFlowControlUri/activerecording')));

  static void activeRecording() => expect(
      resource.CallFlowControl.activeRecording(callFlowControlUri, 'abc'),
      equals(Uri.parse('$callFlowControlUri/activerecording/abc')));

  static void agentStatistics() => expect(
      resource.CallFlowControl.agentStatistics(callFlowControlUri),
      equals(Uri.parse('$callFlowControlUri/agentstatistics')));

  static void agentStatistic() => expect(
      resource.CallFlowControl.agentStatistic(callFlowControlUri, 99),
      equals(Uri.parse('$callFlowControlUri/agentstatistics/99')));

  static void stateReload() => expect(
      resource.CallFlowControl.stateReload(callFlowControlUri),
      equals(Uri.parse('$callFlowControlUri/state/reload')));

  static void channelList() => expect(
      resource.CallFlowControl.channelList(callFlowControlUri),
      equals(Uri.parse('$callFlowControlUri/channel')));

  static void peerList() => expect(
      resource.CallFlowControl.peerList(callFlowControlUri),
      equals(Uri.parse('$callFlowControlUri/peer')));

  static void single() => expect(
      resource.CallFlowControl.single(callFlowControlUri, 'abcde'),
      equals(Uri.parse('$callFlowControlUri/call/abcde')));

  static void pickup() => expect(
      resource.CallFlowControl.pickup(callFlowControlUri, 'abcde'),
      equals(Uri.parse('$callFlowControlUri/call/abcde/pickup')));

  static void originate() => expect(
      resource.CallFlowControl.originate(
          callFlowControlUri,
          '12345678',
          new model.OriginationContext()
            ..dialplan = '12340001'
            ..receptionId = 1
            ..contactId = 2),
      equals(Uri.parse(
          '$callFlowControlUri/call/originate/12345678/dialplan/12340001/reception/1/contact/2')));

  static void park() => expect(
      resource.CallFlowControl.park(callFlowControlUri, 'abcde'),
      equals(Uri.parse('$callFlowControlUri/call/abcde/park')));

  static void hangup() => expect(
      resource.CallFlowControl.hangup(callFlowControlUri, 'abcde'),
      equals(Uri.parse('$callFlowControlUri/call/abcde/hangup')));

  static void transfer() => expect(
      resource.CallFlowControl.transfer(callFlowControlUri, 'abcde', 'edcba'),
      equals(Uri.parse('$callFlowControlUri/call/abcde/transfer/edcba')));

  static void list() => expect(
      resource.CallFlowControl.list(callFlowControlUri),
      equals(Uri.parse('$callFlowControlUri/call')));
}
