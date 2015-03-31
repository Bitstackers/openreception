part of openreception.storage;

abstract class Contact {

  Future<List<Map>> calendarMap (int contactID, int receptionID);

  Future<Model.Contact> get(int contactID);

  Future<List<Model.Contact>> list();

  Future<List<Model.Contact>> listByReception(int receptionID, {Model.ContactFilter filter});

  Future<Model.Contact> getByReception(int contactID, int receptionID);

  Future<Model.Contact> remove(Model.Contact Contact);

  Future<Model.Contact> create(Model.Contact Contact);

  Future<Model.Contact> update(Model.Contact Contact);

  Future<List<Model.CalendarEntry>> calendar (int receptionID, int contactID);

  Future<Model.CalendarEntry> calendarEvent
    (int receptionID, int contactID, int eventID);

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event);

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event);

  Future calendarEventRemove (Model.CalendarEntry event);

}
