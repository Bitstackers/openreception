part of openreception.event;

abstract class ReceptionState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ReceptionChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.receptionChange;

  final int receptionID;
  final String state;

  ReceptionChange (this.receptionID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.receptionID : this.receptionID,
                Key.state       : this.state};

    template[this.eventName] = body;

    return template;
  }

  ReceptionChange.fromMap (Map map) :
    this.receptionID = map[Key.receptionChange][Key.receptionID],
    this.state = map[Key.receptionChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}