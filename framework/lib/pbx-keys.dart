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

library openreception.pbx_keys;

/**
 * This class contains 'or::' namespaced call related String constants.
 */
class ORPbxKey {
  static const String namespace = 'or::';

  static const String agentChannel = 'agent-channel';
  static const String callLock = namespace + 'call-lock';
  static const String callNotify = namespace + 'call-notify';
  static const String callUnlock = namespace + 'call-unlock';
  static const String contactId = namespace + 'cid';
  static const String contextCallId = namespace + 'context-call-id';
  static const String destination = namespace + 'destination';
  static const String emailDateHeader = namespace + 'email-date-header';
  static const String greetingPlayed = namespace + 'greeting-played';
  static const String locked = namespace + 'locked';
  static const String parkingLotEnter = namespace + 'parking-lot-enter';
  static const String parkingLotLeave = namespace + 'parking-lot-leave';
  static const String receptionId = namespace + 'rid';
  static const String ringingStart = namespace + 'ringing-start';
  static const String ringingStop = namespace + 'ringing-stop';
  static const String state = namespace + 'state';
  static const String userId = namespace + 'uid';
  static const String waitQueueEnter = namespace + 'wait-queue-enter';
}

/**
 * This class contains non-namespaced call related String constants. Note that there might be some
 * overlap with keys found in [ORPbxKey]. Use the latter if you need the 'or::' namespace.
 */
class PbxKey {
  static const String agentBeginEpoch = 'agent-begin-epoch';
  static const String agentEndEpoch = 'agent-end-epoch';
  static const String answerEpoch = 'answer_epoch';
  static const String billSec = 'billsec';
  static const String bridgeUuid = 'bridge_uuid';
  static const String callCharge = 'call-charge';
  static const String callSetupCharge = 'call-setup-charge';
  static const String currentApplication = 'current_application';
  static const String custom = 'CUSTOM';
  static const String direction = 'direction';
  static const String endEpoch = 'end_epoch';
  static const String event = 'event';
  static const String eventName = 'Event-Name';
  static const String eventSubclass = 'Event-Subclass';
  static const String externalTransfer = 'external_transfer';
  static const String externalTransferEpoch = 'external-transfer-epoch';
  static const String finalTransferAction = 'final-transfer-action';
  static const String greetLong = 'greet-long';
  static const String greetShort = 'greet-short';
  static const String hangupCause = 'hangup_cause';
  static const String inbound = 'inbound';
  static const String maxFailures = 'max-failures';
  static const String maxTimeouts = 'max-timeouts';
  static const String menuExecApp = 'menu-exec-app';
  static const String menuSub = 'menu-sub';
  static const String menuTop = 'menu-top';
  static const String onFalse = 'on-false';
  static const String onTrue = 'on-true';
  static const String originateSignalBond = 'originate_signal_bond';
  static const String outbound = 'outbound';
  static const String playback = 'playback';
  static const String queued = 'queued';
  static const String ringing = 'ringing';
  static const String signalBond = 'signal_bond';
  static const String sipFromUserStripped = 'sip_from_user_stripped';
  static const String startEpoch = 'start_epoch';
  static const String state = 'state';
  static const String timeout = 'timeout';
  static const String transferHistory = 'transfer_history';
  static const String uuid = 'uuid';
}
