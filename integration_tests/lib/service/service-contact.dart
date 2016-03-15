part of openreception_tests.service;

abstract class Contact {
  static Logger _log = new Logger('$_namespace.Contact');

  /**
   *
   */
  static Future createEvent(ServiceAgent sa) async {
    final nextContactCreateEvent = sa.notifications.firstWhere(
        (e) => e is event.ContactChange && e.state == event.Change.created);
    final created = await sa.createsContact();

    final event.ContactChange createEvent =
        await nextContactCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.cid, equals(created.id));
    expect(createEvent.modifierUid, equals(sa.user.id));
    expect(createEvent.timestamp.difference(new DateTime.now()).inMilliseconds,
        lessThan(0));
  }

  /**
   *
   */
  static Future updateEvent(ServiceAgent sa) async {
    final nextContactpdateEvent = sa.notifications.firstWhere(
        (e) => e is event.ContactChange && e.state == event.Change.updated);
    final created = await sa.createsContact();
    await sa.updatesContact(created);

    final event.ContactChange updateEvent =
        await nextContactpdateEvent.timeout(new Duration(seconds: 3));

    expect(updateEvent.cid, equals(created.id));
    expect(updateEvent.modifierUid, equals(sa.user.id));
    expect(updateEvent.timestamp.difference(new DateTime.now()).inMilliseconds,
        lessThan(0));
  }

  /**
   *
   */
  static Future deleteEvent(ServiceAgent sa) async {
    final nextContactDeleteEvent = sa.notifications.firstWhere(
        (e) => e is event.ContactChange && e.state == event.Change.deleted);
    final created = await sa.createsContact();
    await sa.removesContact(created);

    final event.ContactChange deleteEvent =
        await nextContactDeleteEvent.timeout(new Duration(seconds: 3));

    expect(deleteEvent.cid, equals(created.id));
    expect(deleteEvent.modifierUid, equals(sa.user.id));
    expect(deleteEvent.timestamp.difference(new DateTime.now()).inMilliseconds,
        lessThan(0));
  }
}
