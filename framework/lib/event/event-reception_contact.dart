part of openreception.event;

/**
 * 'Enum' representing different outcomes of an [ReceptionContact] change.
 *
 * TODO (krc): Figure out if this is still needed in to ManagementServer.
 */
abstract class ReceptionContactState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class ReceptionContactChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.receptionContactChange;

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
      Key.contactID   : contactID,
      Key.receptionID : receptionID,
      Key.state       : state};

    template[this.eventName] = body;

    return template;
  }

  ReceptionContactChange.fromMap (Map map) :
    this.contactID = map[Key.receptionContactChange][Key.contactID],
    this.receptionID = map[Key.receptionContactChange][Key.receptionID],
    this.state = map[Key.receptionContactChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}