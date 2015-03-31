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
    this.get (userID).lastActivity = new DateTime.now();
    this.get (userID).state = newState;

    Notification.broadcast(new OREvent.UserState (this.get (userID)).asMap);
  }

  ORModel.UserStatus get (int userID) {
    if (!this._userStatus.containsKey(userID)) {
      this._userStatus[userID] = new ORModel.UserStatus()..userID = userID;
    }

    return this._userStatus[userID];
  }
}
