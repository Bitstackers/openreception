part of openreception_tests.service;

abstract class NotificationService {
  static final Logger _log = new Logger('$_namespace.Notification');

  /**
   *
   */
  static Future eventBroadcast(Iterable<service.NotificationSocket> sockets,
      service.NotificationService service) async {
    final int uid = 99;
    final int modUid = 88;
    final event.UserChange testEvent = new event.UserChange.update(uid, modUid);

    bool isExpectedEvent(event.Event e) =>
        e is event.UserChange &&
        e.updated &&
        e.uid == uid &&
        e.modifierUid == modUid;

    Future<Iterable> eventSubScriptions = Future
        .wait(sockets.map((ns) => ns.eventStream.firstWhere(isExpectedEvent)));

    await service.broadcastEvent(testEvent);

    await eventSubScriptions.timeout(threeSeconds);
  }

  /**
   *
   */
  static Future connectionStateList(
      Iterable<ServiceAgent> sas, service.NotificationService service) async {
    bool userHasConnection(
            ServiceAgent sa, Iterable<model.ClientConnection> connections) =>
        connections
            .where((model.ClientConnection connection) =>
                connection.userID == sa.user.id &&
                connection.connectionCount > 0)
            .length >
        0;

    final Iterable<model.ClientConnection> connections =
        await service.clientConnections();
    expect(sas.every((s) => userHasConnection(s, connections)), isTrue);
    expect(connections.every((model.ClientConnection conn) => conn.userID > 0),
        isTrue);
  }

  /**
   *
   */
  static Future connectionState(Iterable<ServiceAgent> sas,
      service.NotificationService notificationService) async {
    await Future.forEach(sas, (ServiceAgent s) async {
      final model.ClientConnection conn =
          await notificationService.clientConnection(s.user.id);

      expect(conn.connectionCount, greaterThan(0));
      expect(conn.userID, equals(s.user.id));
    });
  }

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future _calendarEntryCreateEvent(model.Owner owner,
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
  static Future _calendarEntryUpdateEvent(model.Owner owner,
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
  static Future _calendarEntryDeleteEvent(model.Owner owner,
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
