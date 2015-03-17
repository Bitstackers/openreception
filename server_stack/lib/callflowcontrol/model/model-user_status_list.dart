part of callflowcontrol.model;

class UserStatusList extends IterableBase<ORModel.UserStatus> {

  static UserStatusList instance = new UserStatusList();

  Iterator get iterator => this._userStatus.values.iterator;
  List         toJson() => this.toList(growable: false);

  /// Singleton reference.
  Map<int, ORModel.UserStatus> _userStatus = {};

  Iterable<Call> activeCallsAt (int userID) =>
      CallList.instance.callsOf (userID).where
         ((Call call) => call.state == CallState.Speaking);

  void update (int userID, String newState) {
    Notification.broadcast({'event'    : 'userState',
                            'userID'   : userID,
                            'oldState' : this.get (userID).state,
                            'newState' : newState});

    this.get (userID).lastActivity = new DateTime.now();
    this.get (userID).state = newState;

  }

  ORModel.UserStatus get (int userID) {
    if (!this._userStatus.containsKey(userID)) {
      this._userStatus[userID] = new ORModel.UserStatus()..userID = userID;
    }

    return this._userStatus[userID];
  }
}
