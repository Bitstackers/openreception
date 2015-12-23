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

class OrfPbxKey {
  static const String namespace = 'orf::';

  static const String callLock = namespace + 'call-lock';
  static const String callNotify = namespace + 'call-notify';
  static const String callPlaybackStart = namespace + 'call-playback-start';
  static const String callPlaybackStop = namespace + 'call-playback-stop';
  static const String callUnlock = namespace + 'call-unlock';
  static const String destination = namespace + 'destination';
  static const String greetingPlayed = namespace + 'greeting-played';
  static const String locked = namespace + 'locked';
  static const String ownerUid = namespace + 'owner_uid';
  static const String parkingLotEnter = namespace + 'parking-lot-enter';
  static const String parkingLotLeave = namespace + 'parking-lot-leave';
  static const String receptionId = namespace + 'rid';
  static const String ringingStart = namespace + 'ringing-start';
  static const String ringingStop = namespace + 'ringing-stop';
  static const String state = namespace + 'state';
  static const String waitQueueEnter = namespace + 'wait-queue-enter';
}

class PbxKey {
  @deprecated static const String callLock = 'openreception::call-lock';
  @deprecated static const String callNotify = 'openreception::call-notify';
  @deprecated static const String callPlaybackStart = 'openreception::call-playback-start';
  @deprecated static const String callPlaybackStop = 'openreception::call-playback-stop';
  @deprecated static const String callUnlock = 'openreception::call-unlock';
  @deprecated static const String destination = 'openreception::destination';
  @deprecated static const String greetingPlayed = 'openreception::greeting-played';
  @deprecated static const String locked = 'openreception::locked';
  @deprecated static const String ownerUid = 'openreception::owner_uid';
  @deprecated static const String parkingLotEnter = 'openreception::parking-lot-enter';
  @deprecated static const String parkingLotLeave = 'openreception::parking-lot-leave';
  @deprecated static const String receptionId = 'reception_id';
  @deprecated static const String ringingStart = 'openreception::ringing-start';
  @deprecated static const String ringingStop = 'openreception::ringing-stop';
  @deprecated static const String state = 'openreception::state';
  @deprecated static const String waitQueueEnter = 'openreception::wait-queue-enter';

  static const String answer = 'answer';
  static const String bridge = 'bridge';
  static const String callOffer = 'call-offer';
  static const String closed = 'closed';
  static const String custom = 'CUSTOM';
  static const String event = 'event';
  static const String eventName = 'Event-Name';
  static const String eventSubclass = 'Event-Subclass';
  static const String externalTransfer = 'external_transfer';
  static const String greetLong = 'greet-long';
  static const String greetShort = 'greet-short';
  static const String hangup = 'hangup';
  static const String log = 'log';
  static const String maxFailures = 'max-failures';
  static const String maxTimeouts = 'max-timeouts';
  static const String menuExecApp = 'menu-exec-app';
  static const String menuSub = 'menu-sub';
  static const String menuTop = 'menu-top';
  static const String onFalse = 'on-false';
  static const String onTrue = 'on-true';
  static const String outbound = 'outbound';
  static const String playback = 'playback';
  static const String queued = 'queued';
  static const String reception = 'reception';
  static const String ringing = 'ringing';
  static const String sleep = 'sleep';
  static const String timeout = 'timeout';
  static const String transfer = 'transfer';
}
