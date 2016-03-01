part of or_test_fw;

class Organization {
  /**
     * Test server behaviour when trying to create a new organization.
     *
     * The expected behaviour is that the server should return the created
     * Organization object and send out a OrganizationChange notification.
     */
  static Future createEvent(ServiceAgent sa, Receptionist receptionist) async {
    final nextOrgCreateEvent = receptionist.notificationSocket.eventStream
        .firstWhere((e) =>
            e is event.OrganizationChange &&
            e.state == event.OrganizationState.CREATED);
    final createdOrganization = await sa.createsOrganization();

    final event.OrganizationChange createEvent =
        await nextOrgCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.orgID, equals(createdOrganization.uuid));
  }

  /**
     * Test server behaviour when trying to update an organization.
     *
     * The expected behaviour is that the server should return the created
     * Organization object and send out a OrganizationChange notification.
     */
  static Future updateEvent(ServiceAgent sa, Receptionist receptionist) async {
    final nextOrgUpdateEvent = receptionist.notificationSocket.eventStream
        .firstWhere((e) =>
            e is event.OrganizationChange &&
            e.state == event.OrganizationState.UPDATED);
    final createdOrganization = await sa.createsOrganization();
    await sa.updatesOrganization(createdOrganization);

    final event.OrganizationChange updateEvent =
        await nextOrgUpdateEvent.timeout(new Duration(seconds: 3));

    expect(updateEvent.orgID, equals(createdOrganization.uuid));
  }

  /**
     * Test server behaviour when trying to delete an organization.
     *
     * The expected behaviour is that the server should return the created
     * Organization object and send out a OrganizationChange notification.
     */
  static Future deleteEvent(ServiceAgent sa, Receptionist receptionist) async {
    final nextOrgDeleteEvent = receptionist.notificationSocket.eventStream
        .firstWhere((e) =>
            e is event.OrganizationChange &&
            e.state == event.OrganizationState.DELETED);
    final createdOrganization = await sa.createsOrganization();
    await sa.deletesOrganization(createdOrganization);

    final event.OrganizationChange deleteEvent =
        await nextOrgDeleteEvent.timeout(new Duration(seconds: 3));

    expect(deleteEvent.orgID, equals(createdOrganization.uuid));
  }
}
