part of controller;

abstract class ContactCalendar {

  static final Logger log = new Logger('$libraryName.ContactCalendar');

  /**
   * Creates or updates a calendar entry object associated with a contact.
   */
  Future<Model.ContactCalendarEntry> save(Model.ContactCalendarEntry entry) {

    if (entry.contactID == Model.Contact.noContact.ID) {
      Error error = new ArgumentError.value(entry, 'entry',
          'Trying to update an a contact calendar entry '
          'without an owner!');

      log.severe(error);

      return new Future.error(() => error);
    }

    if (entry.ID == Model.Contact.noContact.ID) {
      log.finest('Creating new calendarEntry: ${entry.asMap}');
      return Service.Contact.store.calendarEventCreate(entry);
    } else {
      log.finest('Updating calendarEntry: ${entry.asMap}');
      return Service.Contact.store.calendarEventUpdate(entry);
    }
  }

  /**
   * Delete a calendar entry object associated with a contact.
   */
  Future delete(Model.ContactCalendarEntry entry) {
    if (entry.ID == Model.ContactCalendarEntry.noID) {
      Error error = new ArgumentError.value(entry, 'entry',
          'Trying to delete an a contact calendar entry '
          'without an ID!');

      log.severe(error);

      return new Future.error(() => error);
    }
    else {
      log.finest('Deleting calendarEntry: ${entry.asMap}');
      return Service.Contact.store.calendarEventRemove(entry);
    }
  }

  static findEvent (List<ORModel.CalendarEntry> events, int eventID) =>
     events.firstWhere((ORModel.CalendarEntry event) => event.ID == eventID);
}
