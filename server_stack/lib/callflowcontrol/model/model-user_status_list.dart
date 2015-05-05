part of callflowcontrol.model;

class UserStatusList extends IterableBase<ORModel.UserStatus> {

  static UserStatusList instance = new UserStatusList();

  Iterator get iterator => this._userStatus.values.iterator;
  List         toJson() => this.toList(growable: false);
  Future   timeoutDetector;
  final Duration keepAliveTimeout = new Duration(seconds : 10);

  /// Singleton reference.
  Map<int, ORModel.UserStatus> _userStatus = {};

  UserStatusList() {
    _checkTimestamps();
  }

  Iterable<Call> activeCallsAt (int userID) =>
      CallList.instance.callsOf (userID).where
         ((Call call) => call.state == CallState.Speaking);

  void update (int userID, String newState) {
    this.updatetimeStamp(userID);
    this.get (userID).state = newState;

    Notification.broadcast(new OREvent.UserState (this.get (userID)).asMap);
  }

  void updatetimeStamp (int userID) {
    this.get (userID).lastActivity = new DateTime.now();
  }

  ORModel.UserStatus get (int userID) {
    if (!this._userStatus.containsKey(userID)) {
      this._userStatus[userID] = new ORModel.UserStatus()..userID = userID;
    }

    return this._userStatus[userID];
  }

  Future _checkTimestamps() {
    List<ORModel.UserStatus> markedForRemoval = [];

    DateTime now = new DateTime.now();
    this.forEach((ORModel.UserStatus status) {
      if (status.lastActivity != null) {
        Duration timeSinceLastActivity = status.lastActivity.difference(now);
        if (keepAliveTimeout > timeSinceLastActivity){
          log.info ('User with id ${status.userID} was timed out due to '
                 'inactivity. Time since last activty: $timeSinceLastActivity');
          status.state = ORModel.UserState.Unknown;
          Notification.broadcast(new OREvent.UserState
              (this.get (status.userID)).asMap);
          //Remove the user from the map
          //TODO: Check if the user has an active websocket first.
          markedForRemoval.add(status);
        }
      }
    });

    if (markedForRemoval.isNotEmpty) {
      markedForRemoval.map((ORModel.UserStatus status) =>
          this._userStatus.remove(status));
      markedForRemoval.clear();
    }

    return new Future.delayed(keepAliveTimeout, this._checkTimestamps);
  }
}
