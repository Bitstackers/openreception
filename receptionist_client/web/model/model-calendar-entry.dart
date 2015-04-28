part of model;

abstract class CalendarEntry extends ORModel.CalendarEntry {
  static int get noID => ORModel.CalendarEntry.noID;

  CalendarEntry.fromMap(Map map) : super.fromMap(map);

  CalendarEntry.empty();

  CalendarEntry.forContact (int contactID, int receptionID) :
    super.forContact(contactID, receptionID);

  CalendarEntry.forReception (int receptionID) :
    super.forReception(receptionID);
}