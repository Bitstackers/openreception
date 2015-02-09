part of openreception.model;


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
  static const WrappingUp      = 'wrappingUp';
  static const HandlingOffHook = 'handlingOffHook';

  static final List<String> PhoneReadyStates = [Idle, WrappingUp, HandlingOffHook];
  static final Iterable<String> TransitionStates = [Receiving, HangingUp, Transferring, Dialing, Parking, Unparking];

  static phoneIsReady (String state) => PhoneReadyStates.contains(state);
}


abstract class UserStatusJSONKey {
  static const String UserID        = 'userID';
  static const String State         = 'state';
  static const String LastActivity  = 'lastActivity';
  static const String CallsHandled  = 'callsHandled';
  static const String AssignedCalls = 'assignedCalls';
}

class UserStatus {
  int          userID       = User.nullID;
  String       _state       = UserState.Unknown;
  DateTime     lastActivity = null;
  int          callsHandled = 0;


  Map toJson () => this.asMap;

  String get state => this._state;
         set state (String newState) {
           this._state = newState;
         }

  UserStatus();

  UserStatus.fromMap (Map map) {
    this.userID       = map[UserStatusJSONKey.UserID];
    this.state        = map[UserStatusJSONKey.State];
    this.lastActivity = map[UserStatusJSONKey.LastActivity] != null
                         ? Util.unixTimestampToDateTime(map[UserStatusJSONKey.LastActivity])
                         : null;
    this.callsHandled = map[UserStatusJSONKey.CallsHandled];
  }

  Map get asMap =>
      {
          'userID'        : this.userID,
          'state'         : this._state,
          'lastActivity'  : this.lastActivity != null ? Util.dateTimeToUnixTimestamp(this.lastActivity) : null,
          'callsHandled'  : this.callsHandled
      };
}