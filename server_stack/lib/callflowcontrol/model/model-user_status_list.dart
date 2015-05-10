part of callflowcontrol.model;

class UserStatusList extends IterableBase<ORModel.UserStatus> {

  static UserStatusList instance = new UserStatusList();

  Iterator get iterator => this._userStatus.values.iterator;
  List         toJson() => this.toList(growable: false);
  Future   timeoutDetector;
  final Duration keepAliveTimeout = new Duration(hours : 1);

  /// Singleton reference.
  Map<int, ORModel.UserStatus> _userStatus = {};

  UserStatusList() {
    _checkTimestamps();
  }

  bool has (int userID) => this._userStatus.containsKey(userID);

  Iterable<Call> activeCallsAt (int userID) =>
      CallList.instance.callsOf (userID).where
         ((Call call) => call.state == CallState.Speaking);

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

  Future _checkTimestamps() {
    List<ORModel.UserStatus> markedForRemoval = [];

    DateTime now = new DateTime.now();
    this.forEach((ORModel.UserStatus status) {
      if (status.lastActivity != null) {
        int secondsSinceLastActivity = status.lastActivity
          .difference(now).inSeconds.abs();
        if (secondsSinceLastActivity > keepAliveTimeout.inSeconds){
          log.info ('User with id ${status.userID} was timed out due to '
                    'inactivity. Time since last activity: '
                    '${secondsSinceLastActivity}s');

          //TODO: Check if the user has an active websocket first.
          this.logout(status.userID);
          markedForRemoval.add(status);
        }
      }
    });

    if (markedForRemoval.isNotEmpty) {
      markedForRemoval.forEach((ORModel.UserStatus status) =>
          this.remove(status.userID));
      markedForRemoval.clear();
    }

    return new Future.delayed(keepAliveTimeout, this._checkTimestamps);
  }
}
