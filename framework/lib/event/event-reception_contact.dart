part of openreception.event;

abstract class ReceptionContactState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ReceptionContactChange implements Event {

  final DateTime timestamp;

  String get eventName => _Key.receptionContactChange;

  final int receptionID;
  final int contactID;
  final String state;

  ReceptionContactChange (this.contactID, this.receptionID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      _Key.contactID   : contactID,
      _Key.receptionID : receptionID,
      _Key.state       : state};

    template[this.eventName] = body;

    return template;
  }

  ReceptionContactChange.fromMap (Map map) :
    this.contactID = map[_Key.receptionContactChange][_Key.contactID],
    this.receptionID = map[_Key.receptionContactChange][_Key.receptionID],
    this.state = map[_Key.receptionContactChange][_Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[_Key.timestamp]);
}