part of openreception.event;

class UserState implements Event {

  final DateTime timestamp;
  final String eventName = _Key.userState;

  final UserStatus status;

  UserState(UserStatus this.status) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.userState(this);

  UserState.fromMap(Map map)
      : this.status = new UserStatus.fromMap(map),
        this.timestamp = Util.unixTimestampToDateTime(map[_Key.timestamp]);

}
