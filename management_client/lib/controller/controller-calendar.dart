part of management_tool.controller;

class Calendar {
  final service.RESTCalendarStore _calendarService;
  final model.User _appUser;

  Calendar(this._calendarService, this._appUser);

  Future<Iterable<model.CalendarEntryChange>> changes(int entryId) =>
      _calendarService.changes(entryId);

  Future get(model.CalendarEntry entry) =>
      _calendarService.remove(entry.id, _appUser);

  Future<Iterable<model.CalendarEntry>> listContact(int contactId) =>
      _calendarService.list(new model.OwningContact(contactId));

  Future<Iterable<model.CalendarEntry>> listReception(int receptionId) =>
      _calendarService.list(new model.OwningReception(receptionId));

  Future<model.CalendarEntry> create(model.CalendarEntry entry) =>
      _calendarService.create(entry, _appUser);

  Future<model.CalendarEntry> update(model.CalendarEntry entry) =>
      _calendarService.update(entry, _appUser);

  Future remove(model.CalendarEntry entry) =>
      _calendarService.remove(entry.id, _appUser);
}
