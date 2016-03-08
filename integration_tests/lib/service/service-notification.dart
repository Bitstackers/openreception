part of openreception_tests.service;

abstract class NotificationService {
  static final Logger _log = new Logger('$_namespace.Notification');

  static Future eventBroadcast(Iterable<Receptionist> receptionists) {
    receptionists.forEach((Receptionist receptionist) {
      receptionist.eventStack.clear();
    });

    return receptionists.first.pause().then((_) => Future.forEach(
        receptionists,
        (Receptionist receptionist) =>
            receptionist.waitFor(eventType: event.Key.userState)));
  }

  static Future connectionStateList(Iterable<Receptionist> receptionists,
      service.NotificationService notificationService) {
    receptionists.forEach((Receptionist receptionist) {
      receptionist.eventStack.clear();
    });

    bool receptionistHasConnection(Receptionist receptionist,
            Iterable<model.ClientConnection> connections) =>
        connections
            .where((model.ClientConnection connection) =>
                connection.userID == receptionist.user.id &&
                connection.connectionCount > 0)
            .length >
        0;

    return notificationService
        .clientConnections()
        .then((Iterable<model.ClientConnection> connections) {
      expect(
          receptionists.every(
              (Receptionist r) => receptionistHasConnection(r, connections)),
          isTrue);
      expect(
          connections.every((model.ClientConnection conn) => conn.userID > 0),
          isTrue);
    });
  }

  static Future connectionState(Iterable<Receptionist> receptionists,
      service.NotificationService notificationService) {
    receptionists.forEach((Receptionist receptionist) {
      receptionist.eventStack.clear();
    });

    return Future.forEach(receptionists, (Receptionist r) {
      return notificationService
          .clientConnection(r.user.id)
          .then((model.ClientConnection conn) {
        expect(conn.connectionCount, greaterThan(0));
        expect(conn.userID, equals(r.user.id));
      });
    });
  }

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryCreateEvent(model.Owner owner,
      storage.Calendar calendarStore, Receptionist receptionist) async {
    Future<event.CalendarChange> nextCreateEvent =
        receptionist.waitFor(eventType: event.Key.calendarChange);
    model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, receptionist.user);

    event.CalendarChange createEvent = await nextCreateEvent;

    expect(createEvent.eid, equals(createdEntry.id));
    expect(createEvent.state, equals(event.Change.created));
  }

  /**
   * Test server behaviour when trying to update a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryUpdateEvent(model.Owner owner,
      storage.Calendar calendarStore, Receptionist receptionist) async {
    model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, receptionist.user);

    {
      model.CalendarEntry changes = Randomizer.randomCalendarEntry()
        ..id = createdEntry.id
        ..owner = createdEntry.owner;
      createdEntry = changes;
    }

    Future<event.CalendarChange> nextUpdateEvent = receptionist
        .notificationSocket.eventStream
        .firstWhere((event) => (event is event.CalendarChange &&
            event.eid == createdEntry.id &&
            event.state == event.CalendarEntryState.UPDATED))
        .timeout(new Duration(seconds: 10));

    await calendarStore.update(createdEntry, receptionist.user);

    await nextUpdateEvent;
  }

  /**
   * Test server behaviour when trying to delete a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should succeed and send out a
   * CalendarChange Notification.
   */
  static Future calendarEntryDeleteEvent(model.Owner owner,
      storage.Calendar calendarStore, Receptionist receptionist) async {
    model.CalendarEntry createdEntry = await calendarStore.create(
        Randomizer.randomCalendarEntry()..owner = owner, receptionist.user);

    Future<event.CalendarChange> nextRemoveEvent = receptionist
        .notificationSocket.eventStream
        .firstWhere((e) => (e is event.CalendarChange &&
            e.eid == createdEntry.id &&
            e.state == event.Change.deleted))
        .timeout(new Duration(seconds: 10));

    await calendarStore.remove(createdEntry.id, receptionist.user);
    await nextRemoveEvent;
  }

  /**
     *
     */

//  static Future clientConnectionState(Iterable<Receptionist> receptionists) {
//    receptionists.forEach((Receptionist receptionist) {
//      receptionist.eventStack.clear();
//    });
//
//    return receptionists.first.paused().then((_) =>
//      Future.forEach(receptionists, (Receptionist receptionist) =>
//        receptionist.waitFor(eventType : Event.Key.userState)));
//  }

//  static Future eventSend(Iterable<Receptionist> receptionists,
//                              Service.NotificationService notificationService) {
//    // This test make no sense with only two participants
//    expect(receptionists.length, greaterThan(2));
//
//    receptionists.forEach((Receptionist receptionist) {
//      receptionist.eventStack.clear();
//    });
//
//    Iterable<int> recipientUids = receptionists.map((r) => r.user.ID);
//
//    return notificationService.send(recipientUids, new Event.UserState())
//
//    return receptionists.first.paused().then((_) =>
//      Future.forEach(receptionists, (Receptionist receptionist) =>
//        receptionist.waitFor(eventType : Event.Key.userState)));
//  }
}
