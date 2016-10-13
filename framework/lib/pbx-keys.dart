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

library orf.pbx_keys;

/// This class contains '__or__' namespaced call related String constants.
class ORPbxKey {
  static const String _ns = '__or__';

  /// `agentBeginEpoch` key.
  static const String agentBeginEpoch = _ns + 'agent-begin-epoch';

  /// `agentChannel` key.
  static const String agentChannel = _ns + 'agent-channel';

  /// `agentEndEpoch` key.
  static const String agentEndEpoch = _ns + 'agent-end-epoch';

  /// `callLock` key.
  static const String callLock = _ns + 'call-lock';

  /// `callNotify` key.
  static const String callNotify = _ns + 'call-notify';

  /// `callUnlock` key.
  static const String callUnlock = _ns + 'call-unlock';

  /// `contactId` key.
  static const String contactId = _ns + 'cid';

  /// `contextCallId` key.
  static const String contextCallId = _ns + 'context-call-id';

  /// `destination` key.
  static const String destination = _ns + 'destination';

  /// `emailDateHeader` key.
  static const String emailDateHeader = _ns + 'email-date-header';

  /// `externalTransferEpoch` key.
  static const String externalTransferEpoch = _ns + 'external-transfer-epoch';

  /// `greetingPlayed` key.
  static const String greetingPlayed = _ns + 'greeting-played';

  /// `locked` key.
  static const String locked = _ns + 'locked';

  /// `parkingLotEnter` key.
  static const String parkingLotEnter = _ns + 'parking-lot-enter';

  /// `parkingLotLeave` key.
  static const String parkingLotLeave = _ns + 'parking-lot-leave';

  /// `receptionId` key.
  static const String receptionId = _ns + 'rid';

  /// `receptionName` key.
  static const String receptionName = _ns + 'reception-name';

  /// `receptionOpen` key.
  static const String receptionOpen = _ns + 'reception-open';

  /// `ringingStart` key.
  static const String ringingStart = _ns + 'ringing-start';

  /// `ringingStop` key.
  static const String ringingStop = _ns + 'ringing-stop';

  /// `state` key.
  static const String state = _ns + 'state';

  /// `userId` key.
  static const String userId = _ns + 'uid';

  /// `waitQueueEnter` key.
  static const String waitQueueEnter = _ns + 'wait-queue-enter';
}

/// This class contains non-namespaced call related String constants.
///
/// Note that there might be some overlap with keys found in [ORPbxKey].
/// Use the latter if you need the '__OR__' namespace.
class PbxKey {
  /// `answerEpoch` key.
  static const String answerEpoch = 'answer_epoch';

  /// `billSec` key.
  static const String billSec = 'billsec';

  /// `bridgeUuid` key.
  static const String bridgeUuid = 'bridge_uuid';

  /// `callCharge` key.
  static const String callCharge = 'call-charge';

  /// `callSetupCharge` key.
  static const String callSetupCharge = 'call-setup-charge';

  /// `currentApplication` key.
  static const String currentApplication = 'current_application';

  /// `custom` key.
  static const String custom = 'CUSTOM';

  /// `direction` key.
  static const String direction = 'direction';

  /// `endEpoch` key.
  static const String endEpoch = 'end_epoch';

  /// `event` key.
  static const String event = 'event';

  /// `eventName` key.
  static const String eventName = 'Event-Name';

  /// `eventSubclass` key.
  static const String eventSubclass = 'Event-Subclass';

  /// `externalTransfer` key.
  static const String externalTransfer = 'external_transfer';

  /// `finalTransferAction` key.
  static const String finalTransferAction = 'final-transfer-action';

  /// `greetLong` key.
  static const String greetLong = 'greet-long';

  /// `greetShort` key.
  static const String greetShort = 'greet-short';

  /// `hangupCause` key.
  static const String hangupCause = 'hangup_cause';

  /// `inbound` key.
  static const String inbound = 'inbound';

  /// `maxFailures` key.
  static const String maxFailures = 'max-failures';

  /// `maxTimeouts` key.
  static const String maxTimeouts = 'max-timeouts';

  /// `menuExecApp` key.
  static const String menuExecApp = 'menu-exec-app';

  /// `menuSub` key.
  static const String menuSub = 'menu-sub';

  /// `menuTop` key.
  static const String menuTop = 'menu-top';

  /// `onFalse` key.
  static const String onFalse = 'on-false';

  /// `onTrue` key.
  static const String onTrue = 'on-true';

  /// `originateSignalBond` key.
  static const String originateSignalBond = 'originate_signal_bond';

  /// `outbound` key.
  static const String outbound = 'outbound';

  /// `playback` key.
  static const String playback = 'playback';

  /// `queued` key.
  static const String queued = 'queued';

  /// `ringing` key.
  static const String ringing = 'ringing';

  /// `signalBond` key.
  static const String signalBond = 'signal_bond';

  /// `sipFromUserStripped` key.
  static const String sipFromUserStripped = 'sip_from_user_stripped';

  /// `startEpoch` key.
  static const String startEpoch = 'start_epoch';

  /// `state` key.
  static const String state = 'state';

  /// `timeout` key.
  static const String timeout = 'timeout';

  /// `transferHistory` key.
  static const String transferHistory = 'transfer_history';

  /// `uuid` key.
  static const String uuid = 'uuid';
}
