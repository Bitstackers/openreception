part of openreception_tests.service;

abstract class Reception {
  /**
   * Test server behaviour when trying to create a new reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future createEvent(ServiceAgent sa) async {
    final nextOrgCreateEvent = sa.notifications.firstWhere(
        (e) => e is event.ReceptionChange && e.state == event.Change.created);

    final org = await sa.createsOrganization();
    final created = await sa.createsReception(org);

    final event.ReceptionChange createEvent =
        await nextOrgCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.rid, equals(created.id));
    expect(createEvent.modifierUid, equals(sa.user.id));
  }

  /**
     * Test server behaviour when trying to update an reception.
     *
     * The expected behaviour is that the server should return the created
     * Reception object and send out a ReceptionChange notification.
     */
  static Future updateEvent(ServiceAgent sa) async {
    final nextOrgUpdateEvent = sa.notifications.firstWhere(
        (e) => e is event.ReceptionChange && e.state == event.Change.updated);

    final org = await sa.createsOrganization();
    final created = await sa.createsReception(org);
    await sa.updatesReception(created);

    final event.ReceptionChange updateEvent =
        await nextOrgUpdateEvent.timeout(new Duration(seconds: 3));

    expect(updateEvent.rid, equals(created.id));
    expect(updateEvent.modifierUid, equals(sa.user.id));
  }

  /**
     * Test server behaviour when trying to delete an reception.
     *
     * The expected behaviour is that the server should return the created
     * Reception object and send out a ReceptionChange notification.
     */
  static Future deleteEvent(ServiceAgent sa) async {
    final nextOrgDeleteEvent = sa.notifications.firstWhere(
        (e) => e is event.ReceptionChange && e.state == event.Change.deleted);

    final org = await sa.createsOrganization();
    final created = await sa.createsReception(org);
    await sa.removesReception(created);

    final event.ReceptionChange deleteEvent =
        await nextOrgDeleteEvent.timeout(new Duration(seconds: 3));

    expect(deleteEvent.rid, equals(created.id));
    expect(deleteEvent.modifierUid, equals(sa.user.id));
  }
}
