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

void testResourceCallFlowControl() {
  group('Resource.CallFlowControl', () {
    test('stateReload', ResourceCallFlowControl.stateReload);
    test('userStatusMap', ResourceCallFlowControl.userStatusMap);
    test('channelList', ResourceCallFlowControl.channelList);
    test('userStatusIdle', ResourceCallFlowControl.userStatusIdle);
    test('userStatusKeepAlive', ResourceCallFlowControl.userStatusKeepAlive);
    test('userStatusLoggedOut', ResourceCallFlowControl.userStatusLogout);
    test('peerList', ResourceCallFlowControl.peerList);
    test('single', ResourceCallFlowControl.single);
    test('pickup', ResourceCallFlowControl.pickup);
    test('originate', ResourceCallFlowControl.originate);
    test('park', ResourceCallFlowControl.park);
    test('hangup', ResourceCallFlowControl.hangup);
    test('transfer', ResourceCallFlowControl.transfer);
    test('list', ResourceCallFlowControl.list);

    test('activeRecordings', ResourceCallFlowControl.activeRecordings);
    test('activeRecording', ResourceCallFlowControl.activeRecording);
    test('agentStatistics', ResourceCallFlowControl.agentStatistics);
    test('agentStatistic', ResourceCallFlowControl.agentStatistic);
  });
}
abstract class ResourceCallFlowControl {
  static Uri callFlowControlUri = Uri.parse('http://localhost:4242');

  /**
   *
   */
  static void activeRecordings()
    => expect(
        Resource.CallFlowControl.activeRecordings(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/activerecording')));

  /**
   *
   */
  static void activeRecording()
    => expect(
        Resource.CallFlowControl.activeRecording(callFlowControlUri, 'abc'),
        equals(Uri.parse('${callFlowControlUri}/activerecording/abc')));
  /**
   *
   */
  static void agentStatistics()
    => expect(
        Resource.CallFlowControl.agentStatistics(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/agentstatistics')));

  /**
   *
   */
  static void agentStatistic()
    => expect(
        Resource.CallFlowControl.agentStatistic(callFlowControlUri, 99),
        equals(Uri.parse('${callFlowControlUri}/agentstatistics/99')));


  static void stateReload() => expect(
      Resource.CallFlowControl.stateReload(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/state/reload')));

  static void userStatusMap() => expect(
      Resource.CallFlowControl.userStatus(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1')));

  static void channelList() => expect(
      Resource.CallFlowControl.channelList(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/channel/list')));

  static void userStatusIdle() => expect(
      Resource.CallFlowControl.userStatusIdle(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1/idle')));

  static void userStatusKeepAlive() => expect(
      Resource.CallFlowControl.userStateKeepAlive(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1/keep-alive')));

  static void userStatusLogout() => expect(
      Resource.CallFlowControl.userStateLoggedOut(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1/loggedOut')));

  static void peerList() => expect(
      Resource.CallFlowControl.peerList(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/peer/list')));

  static void single() => expect(
      Resource.CallFlowControl.single(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde')));

  static void pickup() => expect(
      Resource.CallFlowControl.pickup(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/pickup')));

  static void originate() => expect(
      Resource.CallFlowControl.originate(callFlowControlUri, '12345678', 1, 2),
      equals(Uri.parse(
          '${callFlowControlUri}/call/originate/12345678/reception/2/contact/1')));

  static void park() => expect(
      Resource.CallFlowControl.park(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/park')));

  static void hangup() => expect(
      Resource.CallFlowControl.hangup(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/hangup')));

  static void transfer() => expect(
      Resource.CallFlowControl.transfer(callFlowControlUri, 'abcde', 'edcba'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/transfer/edcba')));

  static void list() => expect(
      Resource.CallFlowControl.list(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/call')));
}
