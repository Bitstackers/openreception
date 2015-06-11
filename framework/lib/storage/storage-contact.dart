part of openreception.storage;

abstract class Contact {

  Future<Iterable<Map>> calendarMap (int contactID, int receptionID);

  Future<Model.BaseContact> get(int contactID);

  Future<Iterable<Model.BaseContact>> list();

  Future<Iterable<Model.Contact>> listByReception(int receptionID, {Model.ContactFilter filter});

  Future<Model.Contact> getByReception(int contactID, int receptionID);

  Future remove(Model.BaseContact contact);

  Future<Model.BaseContact> create(Model.BaseContact contact);

  Future<Model.BaseContact> update(Model.BaseContact contact);

  Future<Iterable<Model.CalendarEntry>> calendar (int receptionID, int contactID);

  Future<Model.CalendarEntry> calendarEvent
    (int receptionID, int contactID, int eventID);

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event);

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event);

  Future calendarEventRemove (Model.CalendarEntry event);

}
