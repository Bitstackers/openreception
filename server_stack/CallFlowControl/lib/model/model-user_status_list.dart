part of callflowcontrol.model;

class UserStatusList extends IterableBase<UserStatus> {

  static UserStatusList instance = new UserStatusList();

  Iterator get iterator => this._userStatus.values.iterator;
  List         toJson() => this.toList(growable: false);

  /// Singleton reference.
  Map<int, UserStatus> _userStatus = {};

  Iterable<Call> activeCallsAt (int userID) =>
      CallList.instance.callsOf (userID).where
         ((Call call) => call.state == CallState.Speaking);

  void update (userID, String newState) {
    Notification.broadcast({'event' : {'name' : 'userState',
                                       'oldState' : this.get (userID).state,
                                       'newState' : newState}});

    this.get (userID).lastActivity = new DateTime.now();
    this.get (userID).state = newState;

  }

  UserStatus get (int userID) {
    if (!this._userStatus.containsKey(userID)) {
      this._userStatus[userID] = new UserStatus()..userID = userID;
    }

    return this._userStatus[userID];
  }
}

abstract class UserState {
  static const Unknown         = 'unknown';
  static const Idle            = 'idle';
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

  static phoneIsReady (String state) => PhoneReadyStates.contains(state);
}


class UserStatus {
  int          userID       = SharedModel.User.nullID;
  String       _state       = UserState.Unknown;
  DateTime     lastActivity = null;
  int          callsHandled = 0;
  //Set<String>  calls        = new Set<String>();

  Map toJson () => this.asMap;

  String get state => this._state;
         set state (String newState) {
           this._state = newState;
         }

  Map get asMap =>
      {
          'userID'        : this.userID,
          'state'         : this._state,
          'lastActivity'  : this.lastActivity != null ? Util.dateTimeToUnixTimestamp(this.lastActivity) : null,
          'callsHandled'  : this.callsHandled,
          'assignedCalls' : CallList.instance.callsOf (userID)
                              .map((Call call)=> call.ID).toList()
      };
}