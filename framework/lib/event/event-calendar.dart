part of openreception.event;

abstract class CalendarEvent implements Event {

  final DateTime timestamp;

  final CalendarEntry calendarEntry;

  CalendarEvent (CalendarEntry this.calendarEntry) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.calendarEntry(this);

  CalendarEvent.fromMap (Map map) :
    this.calendarEntry = new CalendarEntry.fromMap(map[Key.calendarEntry]),
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}

abstract class CalendarEntryState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class CalendarChange implements Event {

  final DateTime timestamp;

  String get eventName => 'CalendarChange';
  
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
    
    Map body = {Key.EntryID     : this.entryID,
                Key.ReceptionID : this.receptionID,
                Key.ContactID   : this.contactID,
                Key.state       : this.state};
    
    template[Key.CalendarChange] = body;
    
    return template;
  }
      
  CalendarChange.fromMap (Map map) :
    this.entryID = map[Key.CalendarChange][Key.EntryID],
    this.contactID = map[Key.CalendarChange][Key.ContactID],
    this.receptionID = map[Key.CalendarChange][Key.ReceptionID],
    this.state = map[Key.CalendarChange][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}

class ContactCalendarEntryCreate extends CalendarEvent {

  final String   eventName = Key.contactCalendarEntryCreate;

  ContactCalendarEntryCreate (CalendarEntry entry) : super (entry);
  ContactCalendarEntryCreate.fromMap (Map map) : super.fromMap(map);
}

class ContactCalendarEntryUpdate extends CalendarEvent {

  final String   eventName = Key.contactCalendarEntryUpdate;
  ContactCalendarEntryUpdate (CalendarEntry entry) : super (entry);
  ContactCalendarEntryUpdate.fromMap (Map map) : super.fromMap(map);
}

class ContactCalendarEntryDelete extends CalendarEvent {

  final String   eventName = Key.contactCalendarEntryDelete;

  ContactCalendarEntryDelete (CalendarEntry entry) : super (entry);
  ContactCalendarEntryDelete.fromMap (Map map) : super.fromMap(map);
}

class ReceptionCalendarEntryCreate extends CalendarEvent {

  final String   eventName = Key.receptionCalendarEntryCreate;

  ReceptionCalendarEntryCreate (CalendarEntry entry) : super (entry);
  ReceptionCalendarEntryCreate.fromMap (Map map) : super.fromMap(map);
}

class ReceptionCalendarEntryUpdate extends CalendarEvent {

  final String   eventName = Key.receptionCalendarEntryUpdate;
  ReceptionCalendarEntryUpdate (CalendarEntry entry) : super (entry);
  ReceptionCalendarEntryUpdate.fromMap (Map map) : super.fromMap(map);
}

class ReceptionCalendarEntryDelete extends CalendarEvent {

  final String   eventName = Key.receptionCalendarEntryDelete;

  ReceptionCalendarEntryDelete (CalendarEntry entry) : super (entry);
  ReceptionCalendarEntryDelete.fromMap (Map map) : super.fromMap(map);
}
