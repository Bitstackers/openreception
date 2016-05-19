part of openreception_tests.service;

abstract class Calendar {
  static final Logger _log = new Logger('$_namespace.Calendar');

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEntry object and send out a CalendarEvent notification.
   */

  static Future createEvent(ServiceAgent sa, model.Owner owner,
      storage.Calendar calendarStore) async {
    _log.info('Started createEvent test');

    final nextCalendarCreateEvent = (await sa.notifications)
        .firstWhere((e) => e is event.CalendarChange && e.created);

    final createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry(), owner, sa.user);

    final event.CalendarChange createEvent =
        await nextCalendarCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.eid, equals(createdEntry.id));
    expect(createEvent.timestamp.isBefore(new DateTime.now()), isTrue);
    expect(createEvent.modifierUid, equals(sa.user.id));
  }

  /**
   * Test server behaviour when trying to update a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future updateEvent(ServiceAgent sa, model.Owner owner,
      storage.Calendar calendarStore) async {
    _log.info('Started createEvent test');

    final nextCalendarCreateEvent = (await sa.notifications)
        .firstWhere((e) => e is event.CalendarChange && e.updated);

    final createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry(), owner, sa.user);

    await calendarStore.update(
        createdEntry..content += 'Updated', owner, sa.user);

    final event.CalendarChange createEvent =
        await nextCalendarCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.eid, equals(createdEntry.id));
    expect(createEvent.timestamp.isBefore(new DateTime.now()), isTrue);
    expect(createEvent.modifierUid, equals(sa.user.id));
  }

  /**
   * Test server behaviour when trying to delete a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should succeed and send out a
   * CalendarChange Notification.
   */
  static Future deleteEvent(ServiceAgent sa, model.Owner owner,
      storage.Calendar calendarStore) async {
    _log.info('Started createEvent test');

    final nextCalendarCreateEvent = (await sa.notifications)
        .firstWhere((e) => e is event.CalendarChange && e.deleted);

    final createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry(), owner, sa.user);
    await calendarStore.remove(createdEntry.id, owner, sa.user);

    final event.CalendarChange createEvent =
        await nextCalendarCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.eid, equals(createdEntry.id));
    expect(createEvent.timestamp.isBefore(new DateTime.now()), isTrue);
    expect(createEvent.modifierUid, equals(sa.user.id));
  }
}
