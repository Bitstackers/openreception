part of openreception.storage;

/**
 * TODO: Deprecate the calendar*event methods and rename them to calendar*entry.
 */
abstract class Reception {

  Future<Model.Reception> create (Model.Reception reception);

  Future<Model.Reception> get (int receptionID);

  Future<Iterable<Model.Reception>> list ();

  Future<Model.Reception> remove(int receptionID);

  Future<Model.Reception> update (Model.Reception reception);

  Future<Iterable<Model.CalendarEntry>> calendar (int receptionID);

  Future<Model.CalendarEntry> calendarEvent (int receptionID, eventID);

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event);

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event);

  Future calendarEventRemove (Model.CalendarEntry event);

}
