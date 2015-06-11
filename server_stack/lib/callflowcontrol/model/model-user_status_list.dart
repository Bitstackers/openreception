part of callflowcontrol.model;

class UserStatusList extends IterableBase<ORModel.UserStatus> {

  static UserStatusList instance = new UserStatusList();

  Iterator get iterator => this._userStatus.values.iterator;
  List         toJson() => this.toList(growable: false);
  Future   timeoutDetector;
  final Duration keepAliveTimeout = new Duration(hours : 1);

  /// Singleton reference.
  Map<int, ORModel.UserStatus> _userStatus = {};

  UserStatusList();

  bool has (int userID) => this._userStatus.containsKey(userID);

  Iterable<ORModel.Call> activeCallsAt (int userID) =>
      CallList.instance.callsOf (userID).where
         ((ORModel.Call call) => call.state == ORModel.CallState.Speaking);

  void update (int userID, String newState) {
    ORModel.UserStatus status = this.getOrCreate(userID);
    status.state = newState;
    status.lastActivity = new DateTime.now();

    Notification.broadcastEvent(new OREvent.UserState(status));
  }

  void logout (int userID) {
    ORModel.UserStatus status = this.getOrCreate (userID);
    status.state = ORModel.UserState.LoggedOut;

    Notification.broadcastEvent(new OREvent.UserState(status));
  }

  void remove (int userID) {
    log.finest('removing uid:$userID from map');
    this._userStatus.remove(userID);
  }


  void updatetimeStamp (int userID) {
    if (this.getOrCreate (userID) == null) {
      throw new ORStorage.NotFound('');
    }

    this.getOrCreate (userID).lastActivity = new DateTime.now();
  }

  ORModel.UserStatus getOrCreate (int userID) {
    if (!this._userStatus.containsKey(userID)) {
      this._userStatus[userID] =
         new ORModel.UserStatus()..userID = userID;
    }

    return this._userStatus[userID];
  }
}
