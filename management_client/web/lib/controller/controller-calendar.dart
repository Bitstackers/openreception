part of openreception.managementclient.controller;

class Calendar {
  final ORService.RESTContactStore _contactService;
  final ORService.RESTReceptionStore _receptionService;

  Calendar(this._contactService, this._receptionService);

  Future<Iterable<ORModel.CalendarEntry>> listContact(int contactID, int receptionID) =>
      _contactService.calendar(contactID, receptionID);

  Future<Iterable<ORModel.CalendarEntry>> listReception(int receptionID) =>
      _receptionService.calendar(receptionID);

  Future<ORModel.CalendarEntry> create(ORModel.CalendarEntry entry) =>
      _contactService.calendarEventCreate(entry);

  Future<ORModel.CalendarEntry> update(ORModel.CalendarEntry entry) =>
      _contactService.calendarEventUpdate(entry);

  Future<ORModel.CalendarEntry> remove(ORModel.CalendarEntry entry) =>
      _contactService.calendarEventRemove(entry);
}
