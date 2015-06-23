part of openreception.event;

abstract class UserObjectState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class UserChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.userChange;

  final int userID;
  final String state;

  UserChange._internal (this.userID, this.state) :
    timestamp = new DateTime.now();

  factory UserChange.created (int userID) =>
    new UserChange._internal(userID, UserObjectState.CREATED);

  factory UserChange.updated (int userID) =>
    new UserChange._internal(userID, UserObjectState.UPDATED);

  factory UserChange.deleted (int userID) =>
    new UserChange._internal(userID, UserObjectState.DELETED);

  Map toJson() => this.asMap;

  @override
  String toString() => 'UserChange, uid:$userID, state:$state';

  Map get asMap {
    final Map template = EventTemplate._rootElement(this);

    final Map body = {Key.userID : userID,
                Key.state  : state};

    template[this.eventName] = body;

    return template;
  }

  UserChange.fromMap (Map map) :
    userID = map[Key.userChange][Key.userID],
    state = map[Key.userChange][Key.state],
    timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}