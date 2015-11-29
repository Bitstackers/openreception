part of or_test_fw;

runDatabaseTests() {

  group ('Database.User', () {
    Database.User userDB;
    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        userDB = new Database.User(connection);
      });
    });

    tearDown (() => connection.close());

    test ('Non-existing user',
        () => User.nonExistingUser(userDB));

    test ('Existing user',
        () => User.existingUser(userDB));

    test ('Create',
        () => User.createUser(userDB));

    test ('Update',
        () => User.updateUser(userDB));

    test ('Remove',
        () => User.updateUser(userDB));

    test ('List users',
        () => User.listUsers(userDB));

    test ('Available group listing',
        () => User.listAllGroups(userDB));

    test ('groups (known user)',
        () => User.listGroupsOfUser(userDB));

    test ('groups (non-existing user)',
        () => User.listGroupsOfNonExistingUser(userDB));

    test ('group join',
        () => User.joinGroup(userDB));

    test ('group leave',
        () => User.leaveGroup(userDB));

    test ('identity add',
        () => User.addUserIdentity(userDB));

    test ('identity remove',
        () => User.removeUserIdentity(userDB));
  });

  group ('Database.Reception', () {
    Database.Reception receptionStore = null;

    Database.Connection connection;
    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        receptionStore = new Database.Reception(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('Non-existing reception',
        () => Reception.nonExistingReception(receptionStore));

    test ('Existing reception',
        () => Reception.existingReception(receptionStore));

    test ('List receptions',
        () => Reception.listReceptions(receptionStore));

    test ('Reception creation',
        () => Reception.create(receptionStore));

    test ('Non-existing Reception update',
        () => Reception.updateNonExisting(receptionStore));

    test ('Reception invalid update',
        () => Reception.updateInvalid(receptionStore));

    test ('Reception update',
        () => Reception.update(receptionStore));

    test ('Reception removal',
        () => Reception.remove(receptionStore));
  });

  group ('Database.MessageQueue', () {

    Database.MessageQueue messageDB;
    Database.Connection connection;

    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        messageDB = new Database.MessageQueue(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('list',
        () => MessageQueueStore.list(messageDB));
  });

  group ('Database.Message', () {
    Storage.Reception receptionStore;
    Storage.Contact contactStore;
    Transport.Client transport;
    Receptionist r;


    Database.Message messageDB;
    Database.Connection connection;

    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        messageDB = new Database.Message(connection);
      });
    });

    tearDown (() {
      return connection.close();
    });

    test ('list',
        () => MessageStore.list(messageDB));

    test ('get',
        () => MessageStore.get(messageDB));

    setUp(() {

      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        messageDB = new Database.Message(connection);

        transport = new Transport.Client();
        receptionStore = new Service.RESTReceptionStore(Config.receptionStoreUri,
              Config.serverToken, transport);
        contactStore = new Service.RESTContactStore(Config.contactStoreUri,
              Config.serverToken, transport);
        r = ReceptionistPool.instance.aquire();

        return r.initialize();
      });
    });


   tearDown (() {
     receptionStore = null;
     contactStore = null;
     transport.client.close(force : true);
     return connection.close().then((_) => r.teardown());

   });

    test ('create',
        () => MessageStore.create(messageDB, contactStore, receptionStore, r));

    test ('update',
        () => MessageStore.update(messageDB, contactStore, receptionStore, r));

    test ('enqueue',
        () => MessageStore.enqueue(messageDB, contactStore, receptionStore, r));

    test ('remove',
        () => MessageStore.remove(messageDB, contactStore, receptionStore, r));

  });

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