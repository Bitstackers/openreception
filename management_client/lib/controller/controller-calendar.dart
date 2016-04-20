part of management_tool.controller;

class Calendar {
  final service.RESTCalendarStore _calendarService;
  final model.User _appUser;

  Calendar(this._calendarService, this._appUser);

  Future<Iterable<model.Commit>> changes(model.Owner owner, [int eid]) =>
      _calendarService.changes(owner, eid).catchError(_handleError);

  Future get(model.CalendarEntry entry) =>
      _calendarService.remove(entry.id, _appUser).catchError(_handleError);

  Future<Iterable<model.CalendarEntry>> listContact(int contactId) =>
      _calendarService
          .list(new model.OwningContact(contactId))
          .catchError(_handleError);

  Future<Iterable<model.CalendarEntry>> listReception(int receptionId) =>
      _calendarService
          .list(new model.OwningReception(receptionId))
          .catchError(_handleError);

  Future<model.CalendarEntry> create(model.CalendarEntry entry) =>
      _calendarService.create(entry, _appUser).catchError(_handleError);

  Future<model.CalendarEntry> update(model.CalendarEntry entry) =>
      _calendarService.update(entry, _appUser).catchError(_handleError);

  Future remove(model.CalendarEntry entry) =>
      _calendarService.remove(entry.id, _appUser).catchError(_handleError);
}