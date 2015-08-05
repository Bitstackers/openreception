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

part of openreception.model;

/**
 * 'Enum' type representing the different states of a user, in the context of
 * being able to pickup calls. As an example; a user in the the 'idle' state
 * may pick up a call, while a user that is 'paused' may not.
 * UserState does not imply connectivity, so other states such as [PeerState]
 * or [ClientConnection] should always also be checked before detemining wheter
 * a user is connectable or not.
 */
abstract class UserState {
  static const Unknown         = 'unknown';
  static const Idle            = 'idle';
  static const Paused          = 'paused';
  static const Speaking        = 'speaking';
  static const Receiving       = 'receivingCall';
  static const HangingUp       = 'hangingUp';
  static const Transferring    = 'transferring';
  static const Dialing         = 'dialing';
  static const Parking         = 'parking';
  static const Unparking       = 'unParking';
  static const LoggedOut       = 'loggedOut';
  static const WrappingUp      = 'wrappingUp';
  static const HandlingOffHook = 'handlingOffHook';

  /// Valid states for a user to accept a new call.
  static final List<String> PhoneReadyStates =
      [Idle, WrappingUp, HandlingOffHook];

  /// Invalid states for a user to accept a new call.
  static final Iterable<String> TransitionStates =
      [Receiving, HangingUp, Transferring, Dialing, Parking, Unparking];

  /// Convenience method for checking if a phone is ready.
  static phoneIsReady (String state) => PhoneReadyStates.contains(state);
}

class UserStatus {
  int          userID       = User.noID;
  String       _state       = UserState.Unknown;
  String       lastState    = UserState.Unknown;
  DateTime     lastActivity = null;
  int          callsHandled = 0;


  Map toJson () => this.asMap;

  String get state => this._state;
         set state (String newState) {
           this.lastState = this._state;
           this._state = newState;
         }

  UserStatus();

  UserStatus.fromMap (Map map) {
    this.userID       = map[Key.UserID];
    this.state        = map[Key.state];
    this.lastActivity = map[Key.lastActivity] != null
                         ? Util.unixTimestampToDateTime(map[Key.lastActivity])
                         : null;
    this.callsHandled = map[Key.callsHandled];
  }

  Map get asMap =>
      {
          Key.UserID       : this.userID,
          Key.state        : this._state,
          Key.lastState    : this.lastState,
          Key.lastActivity : this.lastActivity != null
            ? Util.dateTimeToUnixTimestamp(this.lastActivity)
            : null,
          Key.callsHandled : this.callsHandled
      };
}