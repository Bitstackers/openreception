part of openreception.event;

abstract class ContactState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ContactChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.contactChange;

  final int contactID;
  final String state;

  ContactChange (this.contactID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.contactID   : this.contactID,
                Key.state       : this.state};

    template[Key.calendarChange] = body;

    return template;
  }

  ContactChange.fromMap (Map map) :
    this.contactID = map[Key.calendarChange][Key.contactID],
    this.state = map[Key.calendarChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}
