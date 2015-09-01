part of or_test_fw;

abstract class RESTCalendarStore {

  static Logger log = new Logger ('$libraryName.RESTCalendarStore');

  /**
   * Test server behaviour when trying to list calendar events associated with
   * a given contact.
   *
   * The expected behaviour is that the server should return a list of
   * CalendarEntry objects.
   */
  static Future existingContactCalendar (Service.RESTCalendarStore calendarService) {
    int receptionId = 1;
    int contactId = 4;

    log.info('Looking up calendar list for contact $contactId@$receptionId.');

    return calendarService.list(new Model.Owner.contact(contactId, receptionId))
      .then((value) => expect(value, isNotNull));

  }

  /**
   * Test server behaviour when trying to list calendar events associated with
   * a given reception.
   *
   * The expected behaviour is that the server should return a list of
   * CalendarEntry objects.
   */
  static Future existingReceptionCalendar (Service.RESTCalendarStore calendarService) {
    int receptionId = 1;

    log.info('Looking up calendar list for reception with id $receptionId.');

    return calendarService.list(new Model.Owner.reception(receptionId))
      .then((value) => expect(value, isNotNull));

  }

}