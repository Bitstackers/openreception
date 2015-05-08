part of openreception.storage;

abstract class Reception {

  // Map versions of the retriever functions.
  Future<Map> getMap (int receptionID);

  Future<List<Map>> listMap ();

  Future<Map> removeMap(int receptionID);

  Future<Map> saveMap (Map receptionMap);

  Future<List<Map>> calendarMap (int receptionID);

  Future<Map> calendarEventMap (int receptionID, int eventID);

  Future<Map> calendarEventCreateMap (Map eventMap);

  Future<Map> calendarEventUpdateMap (Map eventMap);

  Future calendarEventRemoveMap (Map eventMap);

  // Autocasting versions of the retriever functions.
  Future<Model.Reception> get (int receptionID);

  Future<Iterable<Model.Reception>> list ();

  Future<Model.Reception> remove(int receptionID);

  Future<Model.Reception> save (Model.Reception reception);

  Future<List<Model.CalendarEntry>> calendar (int receptionID);

  Future<Model.CalendarEntry> calendarEvent (int receptionID, eventID);

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event);

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event);

  Future calendarEventRemove (Model.CalendarEntry event);

}
