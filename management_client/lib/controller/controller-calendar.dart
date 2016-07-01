part of management_tool.controller;

class Calendar {
  final service.RESTCalendarStore _service;
  final model.User _appUser;

  Calendar(this._service, this._appUser);

  Future get(model.CalendarEntry entry, model.Owner owner) =>
      _service.remove(entry.id, owner, _appUser).catchError(_handleError);

  /**
   * 
   */
  Future<Iterable<model.CalendarEntry>> list(model.Owner owner) =>
      _service.list(owner).catchError(_handleError);

  @deprecated
  Future<Iterable<model.CalendarEntry>> listContact(int contactId) => _service
      .list(new model.OwningContact(contactId))
      .catchError(_handleError);

  @deprecated
  Future<Iterable<model.CalendarEntry>> listReception(int receptionId) =>
      _service
          .list(new model.OwningReception(receptionId))
          .catchError(_handleError);

  Future<model.CalendarEntry> create(
          model.CalendarEntry entry, model.Owner owner) =>
      _service.create(entry, owner, _appUser).catchError(_handleError);

  Future<model.CalendarEntry> update(
          model.CalendarEntry entry, model.Owner owner) =>
      _service.update(entry, owner, _appUser).catchError(_handleError);

  Future remove(model.CalendarEntry entry, model.Owner owner) =>
      _service.remove(entry.id, owner, _appUser).catchError(_handleError);

  Future<String> changelog(model.Owner owner) =>
      _service.changelog(owner).catchError(_handleError);
}
