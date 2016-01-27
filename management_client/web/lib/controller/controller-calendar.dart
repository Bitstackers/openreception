part of openreception.managementclient.controller;

class Calendar {
  final ORService.RESTCalendarStore _calendarService;

  Calendar(this._calendarService);

  Future<Iterable<ORModel.CalendarEntry>> listContact(int contactId) =>
      _calendarService.list(new ORModel.OwningContact(contactId));

  Future<Iterable<ORModel.CalendarEntry>> listReception(int receptionId) =>
      _calendarService.list(new ORModel.OwningReception(receptionId));

  Future<ORModel.CalendarEntry> create(ORModel.CalendarEntry entry, ORModel.User user) =>
      _calendarService.create(entry, user.ID);

  Future<ORModel.CalendarEntry> update(ORModel.CalendarEntry entry, ORModel.User user) =>
      _calendarService.update(entry, user.ID);

  Future remove(ORModel.CalendarEntry entry, ORModel.User user) =>
      _calendarService.remove(entry.ID, user.ID);
}
