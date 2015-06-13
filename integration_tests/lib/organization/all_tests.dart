part of or_test_fw;

runOrganizationTests () {

  group ('service.Organization', () {
    Transport.Client transport = null;
    Service.RESTOrganizationStore organizationStore = null;
    Receptionist r;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => Organization.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => Organization.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      organizationStore = new Service.RESTOrganizationStore
         (Config.organizationStoreUri, Config.serverToken, transport);

    });

    tearDown (() {
      organizationStore = null;
      transport.client.close(force : true);
    });

    test ('Non-existing organization',
        () => Organization.nonExistingOrganization(organizationStore));

    test ('Existing organization',
        () => Organization.existingOrganization(organizationStore));

    test ('Listing',
        () => Organization.listOrganization(organizationStore));

    test ('Contact listing',
        () => Organization.existingOrganizationContacts(organizationStore));

    test ('Contact listing Non-existing organization',
        () => Organization.nonExistingOrganizationContacts(organizationStore));

    test ('Reception listing',
        () => Organization.existingOrganizationReceptions(organizationStore));

    test ('Reception listing Non-existing organization',
        () => Organization.nonExistingOrganizationReceptions(organizationStore));

    test ('Organization creation',
        () => Organization.create(organizationStore));

    test ('Organization update',
        () => Organization.update(organizationStore));

    test ('Organization removal',
        () => Organization.remove(organizationStore));


    setUp (() {
      transport = new Transport.Client();
      organizationStore = new Service.RESTOrganizationStore
         (Config.organizationStoreUri, Config.serverToken, transport);
      r = ReceptionistPool.instance.aquire();

      return r.initialize();
    });

    tearDown (() {
      organizationStore = null;
      transport.client.close(force : true);

      return r.teardown();
    });

    test ('CalendarEntry creation (event presence)',
        () => Organization.createEvent(organizationStore, r));

    test ('CalendarEntry update (event presence)',
        () => Organization.updateEvent(organizationStore, r));

    test ('CalendarEntry creation (event presence)',
        () => Organization.deleteEvent(organizationStore, r));
  });
}