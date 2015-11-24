part of or_test_fw;


runDatabaseTests() {
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