part of openreception.event;

/**
 * 'Enum' representing different outcomes of a [CalendarEntry] change.
 */
abstract class CalendarEntryState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class CalendarChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.calendarChange;

  final int entryID;
  final int contactID;
  final int receptionID;
  final String state;

  CalendarChange (this.entryID, this.contactID, this.receptionID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.entryID     : this.entryID,
                Key.receptionID : this.receptionID,
                Key.contactID   : this.contactID,
                Key.state       : this.state};

    template[Key.calendarChange] = body;

    return template;
  }

  CalendarChange.fromMap (Map map) :
    this.entryID = map[Key.calendarChange][Key.entryID],
    this.contactID = map[Key.calendarChange][Key.contactID],
    this.receptionID = map[Key.calendarChange][Key.receptionID],
    this.state = map[Key.calendarChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}


