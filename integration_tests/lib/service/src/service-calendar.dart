part of or_test_fw;

abstract class RESTCalendarStore {
  static Logger _log = new Logger('$libraryName.RESTCalendarStore');

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryCreateEvent(Model.Owner owner,
      Storage.Calendar calendarStore, Receptionist receptionist) async {
    Future<Event.CalendarChange> nextCreateEvent =
        receptionist.waitFor(eventType: Event.Key.calendarChange);
    Model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, receptionist.user.ID);

    Event.CalendarChange createEvent = await nextCreateEvent;

    expect(createEvent.entryID, equals(createdEntry.ID));
    expect(createEvent.state, equals(Event.CalendarEntryState.CREATED));

    await calendarStore.purge(createdEntry.ID);
  }

  /**
   * Test server behaviour when trying to update a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryUpdateEvent(Model.Owner owner,
      Storage.Calendar calendarStore, Receptionist receptionist) async {
    Model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, receptionist.user.ID);

    {
      Model.CalendarEntry changes = Randomizer.randomCalendarEntry()
        ..ID = createdEntry.ID
        ..owner = createdEntry.owner;
      createdEntry = changes;
    }

    Future<Event.CalendarChange> nextUpdateEvent = receptionist
        .notificationSocket.eventStream
        .firstWhere((event) => (event is Event.CalendarChange &&
            event.entryID == createdEntry.ID &&
            event.state == Event.CalendarEntryState.UPDATED))
        .timeout(new Duration(seconds: 10));

    await calendarStore.update(createdEntry, receptionist.user.ID);

    await nextUpdateEvent;
  }

  /**
   * Test server behaviour when trying to delete a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should succeed and send out a
   * CalendarChange Notification.
   */
  static Future calendarEntryDeleteEvent(Model.Owner owner,
      Storage.Calendar calendarStore, Receptionist receptionist) async {
    Model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, receptionist.user.ID);

    Future<Event.CalendarChange> nextRemoveEvent = receptionist
        .notificationSocket.eventStream
        .firstWhere((event) => (event is Event.CalendarChange &&
            event.entryID == createdEntry.ID &&
            event.state == Event.CalendarEntryState.DELETED))
        .timeout(new Duration(seconds: 10));

    await calendarStore.remove(createdEntry.ID, receptionist.user.ID);
    await nextRemoveEvent;
  }
}
