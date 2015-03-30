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

  Future<List<Model.CalendarEvent>> calendar (int receptionID, int contactID);

  Future<Model.CalendarEvent> calendarEvent
    (int receptionID, int contactID, int eventID);

  Future<Model.CalendarEvent> calendarEventCreate (Model.CalendarEvent event);

  Future<Model.CalendarEvent> calendarEventUpdate (Model.CalendarEvent event);

  Future calendarEventRemove (Model.CalendarEvent event);

}
