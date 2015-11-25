part of or_test_fw;

runDatabaseTests() {

  group ('Database.Endpoint', () {
    Database.Endpoint endpointDB;
    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        endpointDB = new Database.Endpoint(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('list',
        () => ContactStore.endpoints(endpointDB));

    test ('create',
        () => ContactStore.endpointCreate(endpointDB));

    test ('remove',
        () => ContactStore.endpointRemove(endpointDB));

    test ('update',
        () => ContactStore.endpointUpdate(endpointDB));

  });


  group ('Database.DistributionList', () {
    Database.DistributionList distributionListDB;
    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        distributionListDB = new Database.DistributionList(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('list',
        () => ContactStore.distributionList(distributionListDB));

    test ('create',
        () => ContactStore.distributionRecipientAdd(distributionListDB));

    test ('remove',
        () => ContactStore.distributionRecipientRemove(distributionListDB));
  });

  group ('Database.Contact', () {
    Database.Contact contactDB;
    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        contactDB = new Database.Contact(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('phones',
        () => ContactStore.phones(contactDB));

    test ('listByReception',
        () => ContactStore.listByReception(contactDB));

    test ('getByReception',
        () => ContactStore.getByReception(contactDB));

    test ('organizationContacts',
        () => ContactStore.organizationContacts(contactDB));

    test ('organizations',
        () => ContactStore.organizations(contactDB));

    test ('organizations',
        () => ContactStore.organizations(contactDB));

    test ('receptions',
        () => ContactStore.receptions(contactDB));

    test ('list',
        () => ContactStore.list(contactDB));

    test ('get',
        () => ContactStore.get(contactDB));

    test ('create',
        () => ContactStore.create(contactDB));

    test ('update',
        () => ContactStore.update(contactDB));

    test ('remove',
        () => ContactStore.remove(contactDB));


    test ('addToReception',
        () => ContactStore.addToReception(contactDB));

    test ('updateInReception',
        () => ContactStore.updateInReception(contactDB));

    test ('deleteFromReception',
        () => ContactStore.deleteFromReception(contactDB));

  });

  group ('Database.Calendar', () {
    Database.Calendar calendarDB;
    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        calendarDB = new Database.Calendar(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('list',
        () => ContactStore.existingContactCalendar(calendarDB));

//    test ('create',
//        () => ContactStore.distributionRecipientAdd(distributionListDB));
//
//    test ('remove',
//        () => ContactStore.distributionRecipientRemove(distributionListDB));
  });

  group ('Database.Ivr', () {
    Database.Ivr ivrStore;
    Database.Connection connection;
    setUp(() {
      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        ivrStore = new Database.Ivr(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('create',
        () => IvrStore.create(ivrStore));

    test ('get',
        () => IvrStore.get(ivrStore));

    test ('list',
        () => IvrStore.list(ivrStore));

    test ('remove',
        () => IvrStore.remove(ivrStore));

    test ('update',
        () => IvrStore.update(ivrStore));
  });

  group ('Database.ReceptionDialplan', () {
    Database.ReceptionDialplan receptionDialplanStore;
    Database.Connection connection;
    setUp(() {
      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        receptionDialplanStore = new Database.ReceptionDialplan(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('create',
        () => ReceptionDialplanStore.create(receptionDialplanStore));

    test ('get',
        () => ReceptionDialplanStore.get(receptionDialplanStore));

    test ('list',
        () => ReceptionDialplanStore.list(receptionDialplanStore));

    test ('remove',
        () => ReceptionDialplanStore.remove(receptionDialplanStore));

    test ('update',
        () => ReceptionDialplanStore.update(receptionDialplanStore));
  });
}