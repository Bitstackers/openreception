part of management_tool.controller;

class Calendar {
  final service.RESTCalendarStore _calendarService;

  Calendar(this._calendarService);

  Future<Iterable<model.CalendarEntryChange>> changes(int entryId) =>
      _calendarService.changes(entryId);

  Future(model.CalendarEntry entry, model.User user) =>
      _calendarService.remove(entry.ID, user.id);

  Future<Iterable<model.CalendarEntry>> listContact(int contactId,
          {bool deleted: false}) =>
      _calendarService.list(new model.OwningContact(contactId),
          deleted: deleted);

  Future<Iterable<model.CalendarEntry>> listReception(int receptionId,
          {bool deleted: false}) =>
      _calendarService.list(new model.OwningReception(receptionId),
          deleted: deleted);

  Future<model.CalendarEntry> create(
          model.CalendarEntry entry, model.User user) =>
      _calendarService.create(entry, user.id);

  Future<model.CalendarEntry> update(
          model.CalendarEntry entry, model.User user) =>
      _calendarService.update(entry, user.id);

  Future remove(model.CalendarEntry entry, model.User user,
          {bool purge: false}) =>
      purge
          ? _calendarService.purge(entry.ID)
          : _calendarService.remove(entry.ID, user.id);
}
