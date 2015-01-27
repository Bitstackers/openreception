part of openreception.storage;

abstract class Contact {

  Future<Model.Contact> get(int organizationID);

  Future<List<Model.Contact>> list();

  Future<Model.Contact> remove(Model.Contact Contact);

  Future<Model.Contact> create(Model.Contact Contact);

  Future<Model.Contact> update(Model.Contact Contact);

  Future<List<Model.CalendarEvent>> calendar (int receptionID, int contactID);

  Future<Model.CalendarEvent> calendarEvent (int receptionID, int contactID, eventID);

  Future<Model.CalendarEvent> calendarEventCreate (Model.CalendarEvent event);

  Future<Model.CalendarEvent> calendarEventUpdate (Model.CalendarEvent event);

  Future calendarEventRemove (Model.CalendarEvent event);

}
