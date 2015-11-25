part of or_test_fw;

runOrganizationTests () {
  group ('Database.Organization', () {
    Database.Organization organizationDB;
    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        organizationDB = new Database.Organization(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('create',
        () => Organization.create(organizationDB));

    test ('update',
        () => Organization.update(organizationDB));

    test ('remove',
        () => Organization.remove(organizationDB));

    test ('get',
        () => Organization.existingOrganization(organizationDB));

    test ('get (non-existing)',
        () => Organization.nonExistingOrganization(organizationDB));

    test ('list',
        () => Organization.list(organizationDB));

    test ('Contact list',
        () => Organization.existingOrganizationContacts(organizationDB));

    test ('Contact list (non-existing organization)',
        () => Organization.nonExistingOrganizationContacts(organizationDB));

    test ('Reception listing',
        () => Organization.existingOrganizationReceptions(organizationDB));

    test ('Reception listing Non-existing organization',
        () => Organization.nonExistingOrganizationReceptions(organizationDB));

  });

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
        () => Organization.list(organizationStore));

    test ('Contact listing',
        () => Organization.existingOrganizationContacts(organizationStore));

    test ('Contact listing Non-existing organization',
        () => Organization.nonExistingOrganizationContacts(organizationStore));

    test ('Reception listing',
        () => Organization.existingOrganizationReceptions(organizationStore));

    test ('Reception listing Non-existing organization',
        () => Organization.nonExistingOrganizationReceptions(organizationStore));

    test ('Empty/Invalid Organization creation',
        () => Organization.createEmpty(organizationStore));

    test ('Organization creation',
        () => Organization.create(organizationStore));

    test ('Organization Invalid update',
        () => Organization.updateInvalid(organizationStore));

    test ('Organization update',
        () => Organization.update(organizationStore));

    test ('Organization removal',
        () => Organization.remove(organizationStore));

    test ('Non-existing organization removal',
        () => Organization.removeNonExisting(organizationStore));


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
      ReceptionistPool.instance.release(r);

      return r.teardown();
    });

    test ('Organization creation (event presence)',
        () => Organization.createEvent(organizationStore, r));

    test ('Organization update (event presence)',
        () => Organization.updateEvent(organizationStore, r));

    test ('Organization removal (event presence)',
        () => Organization.deleteEvent(organizationStore, r));
  });
}