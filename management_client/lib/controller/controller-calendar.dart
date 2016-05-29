part of management_tool.controller;

class Calendar {
  final service.RESTCalendarStore _calendarService;
  final model.User _appUser;

  Calendar(this._calendarService, this._appUser);

  Future<Iterable<model.Commit>> changes(model.Owner owner, [int eid]) =>
      _calendarService.changes(owner, eid).catchError(_handleError);

  Future get(model.CalendarEntry entry, model.Owner owner) => _calendarService
      .remove(entry.id, owner, _appUser)
      .catchError(_handleError);

  Future<Iterable<model.CalendarEntry>> listContact(int contactId) =>
      _calendarService
          .list(new model.OwningContact(contactId))
          .catchError(_handleError);

  Future<Iterable<model.CalendarEntry>> listReception(int receptionId) =>
      _calendarService
          .list(new model.OwningReception(receptionId))
          .catchError(_handleError);

  Future<model.CalendarEntry> create(
          model.CalendarEntry entry, model.Owner owner) =>
      _calendarService.create(entry, owner, _appUser).catchError(_handleError);

  Future<model.CalendarEntry> update(
          model.CalendarEntry entry, model.Owner owner) =>
      _calendarService.update(entry, owner, _appUser).catchError(_handleError);

  Future remove(model.CalendarEntry entry, model.Owner owner) =>
      _calendarService
          .remove(entry.id, owner, _appUser)
          .catchError(_handleError);
}
