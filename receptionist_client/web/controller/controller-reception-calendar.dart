part of controller;

abstract class ReceptionCalendar {

  static final Logger log = new Logger('$libraryName.ReceptionCalendar');

  /**
   * Creates or updates a calendar entry object associated with a reception.
   */
  static Future<Model.ReceptionCalendarEntry> save(Model.ReceptionCalendarEntry entry){
    if (entry.receptionID == Model.Reception.noReception.ID) {
      Error error = new ArgumentError.value(entry, 'entry',
          'Trying to update an a reception calendar entry '
          'without an owner!');

      log.severe(error);

      return new Future.error(() => error);
    }

    if (entry.ID == Model.ReceptionCalendarEntry.noID) {
      log.finest('Creating new calendarEntry: ${entry.asMap}');
      return Service.Reception.store.calendarEventCreate(entry);
    } else {
      log.finest('Updating calendarEntry: ${entry.asMap}');
      return Service.Reception.store.calendarEventUpdate(entry);
    }
  }

  /**
   * Delete a calendar entry object associated with a reception.
   */
  static Future delete(Model.ReceptionCalendarEntry entry) {
    if (entry.ID == Model.ReceptionCalendarEntry.noID) {
      Error error = new ArgumentError.value(entry, 'entry',
          'Trying to delete an a reception calendar entry '
          'without an ID!');

      log.severe(error);

      return new Future.error(() => error);
    }
    else {
      log.finest('Deleting calendarEntry: ${entry.asMap}');
      return Service.Reception.store.calendarEventRemove(entry);
    }
  }
}
