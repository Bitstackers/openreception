part of openreception.event;

abstract class MessageChangeState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class MessageChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.messageChange;

  final int messageID;
  final String state;

  MessageChange (this.messageID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.messageID   : this.messageID,
                Key.state       : this.state};

    template[this.eventName] = body;

    return template;
  }

  MessageChange.fromMap (Map map) :
    this.messageID = map[Key.messageChange][Key.messageID],
    this.state = map[Key.messageChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}
