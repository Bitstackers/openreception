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

    DateTime now = new DateTime.now();
    this.forEach((ORModel.UserStatus status) {
      if (status.lastActivity != null) {
        Duration timeSinceLastActivity = status.lastActivity.difference(now);
        if (timeSinceLastActivity > keepAliveTimeout){
          log.info ('User with id ${status.userID} was timed out due to '
                  'inactivity. Time since last activty: $timeSinceLastActivity');
          status.state = ORModel.UserState.Unknown;
        }
      }
    });

    return new Future.delayed(keepAliveTimeout, this._checkTimestamps);
  }
}
