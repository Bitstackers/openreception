part of openreception.storage;

abstract class Reception {

  Future<Model.Reception> get (int receptionID);

  Future<List<Model.ReceptionStub>> list (); //{int limit: 100, Model.ReceptionFilter filter}

  Future<Model.Reception> remove(int receptionID);

  Future<Model.Reception> save (Model.Reception reception);

  Future<List<Model.CalendarEvent>> calendar (int receptionID);

  Future<Model.CalendarEvent> calendarEvent (int receptionID, eventID);

  Future<Model.CalendarEvent> calendarEventCreate (Model.CalendarEvent event);

  Future<Model.CalendarEvent> calendarEventUpdate (Model.CalendarEvent event);

  Future calendarEventRemove (Model.CalendarEvent event);




}
