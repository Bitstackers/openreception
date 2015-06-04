part of openreception.event;

abstract class ContactEntryState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ContactChange implements Event {

  final DateTime timestamp;

  String get eventName => _Key.contactChange;

  final int contactID;
  final String state;

  ContactChange (this.contactID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {_Key.contactID   : this.contactID,
                _Key.state       : this.state};

    template[_Key.calendarChange] = body;

    return template;
  }

  ContactChange.fromMap (Map map) :
    this.contactID = map[_Key.calendarChange][_Key.contactID],
    this.state = map[_Key.calendarChange][_Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[_Key.timestamp]);
}
