part of openreception.event;

/**
 * Event that spawns whenever a user changes its call-handling state.
 */
class UserState implements Event {

  final DateTime timestamp;
  final String eventName = Key.userState;

  final UserStatus status;

  UserState(UserStatus this.status) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.userState(this);

  UserState.fromMap(Map map)
      : this.status = new UserStatus.fromMap(map),
        this.timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);

}
