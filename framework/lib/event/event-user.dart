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

  UserChange (this.userID, this.state) :
    timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.userID : userID,
                Key.state  : state};

    template[this.eventName] = body;

    return template;
  }

  UserChange.fromMap (Map map) :
    userID = map[Key.userChange][Key.userID],
    state = map[Key.userChange][Key.state],
    timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}