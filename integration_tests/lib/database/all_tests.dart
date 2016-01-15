part of or_test_fw;

/**
 * Run all database tests.
 */
runDatabaseTests() {
  _databaseUserTests();
  _databaseReceptionTests();
  _databaseMessageQueue();
  _databaseMessageTests();
  _databaseEndpointTests();
  _databaseDistributionListTests();
  _databaseContactTests();
  _databaseIvrTests();
  _databaseReceptionDialplanTests();
  _databaseCalenderTests();
}

/**
 * Tests for user database.
 */
_databaseUserTests() {
  group('Database.User', () {
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

    tearDown(() => connection.close());

    test('Non-existing user', () => User.nonExistingUser(userDB));

    test('Existing user', () => User.existingUser(userDB));

    test('Create', () => User.createUser(userDB));

    test('Update', () => User.updateUser(userDB));

    test('Remove', () => User.updateUser(userDB));

    test('List users', () => User.listUsers(userDB));

    test('Available group listing', () => User.listAllGroups(userDB));

    test('groups (known user)', () => User.listGroupsOfUser(userDB));

    test('groups (non-existing user)',
        () => User.listGroupsOfNonExistingUser(userDB));

    test('group join', () => User.joinGroup(userDB));

    test('group leave', () => User.leaveGroup(userDB));

    test('identity add', () => User.addUserIdentity(userDB));

    test('identity remove', () => User.removeUserIdentity(userDB));
  });
}

/**
 * Tests for reception database.
 */
_databaseReceptionTests() {
  group('Database.Reception', () {
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

    tearDown(() {
      return connection.close();
    });

    test('Non-existing reception',
        () => Reception.nonExistingReception(receptionStore));

    test('Existing reception',
        () => Reception.existingReception(receptionStore));

    test('List receptions', () => Reception.listReceptions(receptionStore));

    test('Reception creation', () => Reception.create(receptionStore));

    test('Non-existing Reception update',
        () => Reception.updateNonExisting(receptionStore));

    test('Reception invalid update',
        () => Reception.updateInvalid(receptionStore));

    test('Reception update', () => Reception.update(receptionStore));

    test('Reception removal', () => Reception.remove(receptionStore));
  });
}

/**
 * Message queue database tests.
 */
_databaseMessageQueue() {
  group('Database.MessageQueue', () {
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

    tearDown(() {
      return connection.close();
    });

    test('list', () => MessageQueueStore.list(messageDB));
  });
}

/**
 * Message database tests.
 */
_databaseMessageTests() {
  Storage.DistributionList dlStore;
  Storage.Endpoint epStore;

  group('Database.Message', () {
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

    tearDown(() {
      return connection.close();
    });

    test('list', () => MessageStore.list(messageDB));

    test('get', () => MessageStore.get(messageDB));

    setUp(() {
      return Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        messageDB = new Database.Message(connection);

        transport = new Transport.Client();
        receptionStore = new Service.RESTReceptionStore(
            Config.receptionStoreUri, Config.serverToken, transport);
        contactStore = new Service.RESTContactStore(
            Config.contactStoreUri, Config.serverToken, transport);
        r = ReceptionistPool.instance.aquire();
        dlStore = new Service.RESTDistributionListStore(
            Config.contactStoreUri, r.authToken, transport);
        epStore = new Service.RESTEndpointStore(
            Config.contactStoreUri, r.authToken, transport);
        return r.initialize();
      });
    });

    tearDown(() {
      receptionStore = null;
      contactStore = null;
      transport.client.close(force: true);
      return connection.close().then((_) => r.teardown());
    });

    test(
        'create',
        () => MessageStore.create(
            messageDB, contactStore, receptionStore, dlStore, epStore, r));

    test(
        'update',
        () => MessageStore.update(
            messageDB, contactStore, receptionStore, dlStore, epStore, r));

    test(
        'enqueue',
        () => MessageStore.enqueue(
            messageDB, contactStore, receptionStore, dlStore, epStore, r));

    test(
        'remove',
        () => MessageStore.remove(
            messageDB, contactStore, receptionStore, dlStore, epStore, r));
  });
}

/**
 *
 */
_databaseEndpointTests() {
  group('Database.Endpoint', () {
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

    tearDown(() {
      return connection.close();
    });

    test('list', () => ContactStore.endpoints(endpointDB));

    test('create', () => ContactStore.endpointCreate(endpointDB));

    test('remove', () => ContactStore.endpointRemove(endpointDB));

    test('update', () => ContactStore.endpointUpdate(endpointDB));
  });
}

/**
 *
 */
_databaseDistributionListTests() {
  group('Database.DistributionList', () {
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

    tearDown(() {
      return connection.close();
    });

    test('list', () => ContactStore.distributionList(distributionListDB));

    test('create',
        () => ContactStore.distributionRecipientAdd(distributionListDB));

    test('remove',
        () => ContactStore.distributionRecipientRemove(distributionListDB));
  });
}

/**
 *
 */
_databaseContactTests() {
  group('Database.Contact', () {
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

    tearDown(() {
      return connection.close();
    });

    test('phones', () => ContactStore.phones(contactDB));

    test('listByReception', () => ContactStore.listByReception(contactDB));

    test('getByReception', () => ContactStore.getByReception(contactDB));

    test('organizationContacts',
        () => ContactStore.organizationContacts(contactDB));

    test('organizations', () => ContactStore.organizations(contactDB));

    test('organizations', () => ContactStore.organizations(contactDB));

    test('receptions', () => ContactStore.receptions(contactDB));

    test('list', () => ContactStore.list(contactDB));

    test('get', () => ContactStore.get(contactDB));

    test('create', () => ContactStore.create(contactDB));

    test('update', () => ContactStore.update(contactDB));

    test('remove', () => ContactStore.remove(contactDB));

    test('addToReception', () => ContactStore.addToReception(contactDB));

    test('updateInReception', () => ContactStore.updateInReception(contactDB));

    test('deleteFromReception',
        () => ContactStore.deleteFromReception(contactDB));
  });
}

/**
 *
 */
_databaseCalenderTests() {
  group('Database.Calendar', () {
    Database.Calendar calendarDB;
    Database.Connection connection;
    Database.Contact contactDB;
    Database.Reception receptionDB;
    Database.User userDB;
    Model.BaseContact contact;
    Model.Reception reception;
    Model.Owner owner;
    Model.User creator;

    setUp(() async {
      await Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        calendarDB = new Database.Calendar(connection);
        contactDB = new Database.Contact(connection);
        userDB = new Database.User(connection);
      });

      contact = await contactDB.create(Randomizer.randomBaseContact());
      creator = await userDB.create(Randomizer.randomUser());

      owner = new Model.OwningContact(contact.id);
    });

    tearDown(() async {
      await contactDB.remove(contact.id);
      await userDB.remove(creator.ID);

      return connection.close();
    });

    test('get (non-existing)',
        () => StorageCalendar.getNonExistingEntry(calendarDB));

    test('create (contact owner)',
        () => StorageCalendar.create(owner, calendarDB, creator));

    test('update (contact owner)',
        () => StorageCalendar.update(owner, calendarDB, creator));

    test('get (contact owner)',
        () => StorageCalendar.get(owner, calendarDB, creator));

    test('list (contact owner)',
        () => StorageCalendar.list(owner, calendarDB, creator));

    test('remove (contact owner)',
        () => StorageCalendar.remove(owner, calendarDB, creator));

    test('purge (contact owner)',
        () => StorageCalendar.purge(owner, calendarDB, creator));

    test('change listing on create (contact owner)',
        () => StorageCalendar.changeOnCreate(owner, calendarDB, creator));

    test('latest change on create (contact owner)',
        () => StorageCalendar.latestChangeOnCreate(owner, calendarDB, creator));

    test('change listing on update (contact owner)',
        () => StorageCalendar.changeOnUpdate(owner, calendarDB, creator));

    test('latest change on update (contact owner)',
        () => StorageCalendar.latestChangeOnUpdate(owner, calendarDB, creator));

    test('change listing on remove (contact owner)',
        () => StorageCalendar.changeOnRemove(owner, calendarDB, creator));

    test('latest change on remove (contact owner)',
        () => StorageCalendar.latestChangeOnRemove(owner, calendarDB, creator));

    setUp(() async {
      await Database.Connection
          .connect(Config.dbDSN)
          .then((Database.Connection conn) {
        connection = conn;
        calendarDB = new Database.Calendar(connection);
        userDB = new Database.User(connection);
        receptionDB = new Database.Reception(connection);
      });

      reception = await receptionDB.create(Randomizer.randomReception());
      creator = await userDB.create(Randomizer.randomUser());
      owner = new Model.OwningReception(reception.ID);
    });

    tearDown(() async {
      await receptionDB.remove(reception.ID);
      await userDB.remove(creator.ID);

      return connection.close();
    });

    test('create (reception owner)',
        () => StorageCalendar.create(owner, calendarDB, creator));

    test('update (reception owner)',
        () => StorageCalendar.update(owner, calendarDB, creator));

    test('get (reception owner)',
        () => StorageCalendar.get(owner, calendarDB, creator));

    test('list (reception owner)',
        () => StorageCalendar.list(owner, calendarDB, creator));

    test('remove (reception owner)',
        () => StorageCalendar.remove(owner, calendarDB, creator));

    test('purge (reception owner)',
        () => StorageCalendar.purge(owner, calendarDB, creator));

    test('change listing on create (reception owner)',
        () => StorageCalendar.changeOnCreate(owner, calendarDB, creator));

    test('latest change on create (reception owner)',
        () => StorageCalendar.latestChangeOnCreate(owner, calendarDB, creator));

    test('change listing on update (reception owner)',
        () => StorageCalendar.changeOnUpdate(owner, calendarDB, creator));

    test('latest change on update (reception owner)',
        () => StorageCalendar.latestChangeOnUpdate(owner, calendarDB, creator));

    test('change listing on remove (reception owner)',
        () => StorageCalendar.changeOnRemove(owner, calendarDB, creator));

    test('latest change on remove (reception owner)',
        () => StorageCalendar.latestChangeOnRemove(owner, calendarDB, creator));
  });
}

/**
 *
 */
_databaseIvrTests() {
  group('Database.Ivr', () {
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

    tearDown(() {
      return connection.close();
    });

    test('create', () => StorageIvr.create(ivrStore));

    test('get', () => StorageIvr.get(ivrStore));

    test('list', () => StorageIvr.list(ivrStore));

    test('remove', () => StorageIvr.remove(ivrStore));

    test('update', () => StorageIvr.update(ivrStore));
  });
}

/**
 *
 */
_databaseReceptionDialplanTests() {
  group('Database.ReceptionDialplan', () {
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

    tearDown(() {
      return connection.close();
    });

    test('create', () => ReceptionDialplanStore.create(receptionDialplanStore));

    test('get', () => ReceptionDialplanStore.get(receptionDialplanStore));

    test('list', () => ReceptionDialplanStore.list(receptionDialplanStore));

    test('remove', () => ReceptionDialplanStore.remove(receptionDialplanStore));

    test('update', () => ReceptionDialplanStore.update(receptionDialplanStore));
  });
}
