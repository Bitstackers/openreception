part of or_test_fw;

void runCalendarTests () {

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


  group ('RESTCalendarStore', () {
    Transport.Client transport = null;
    Service.RESTCalendarStore calendarStore;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => ContactStore.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => ContactStore.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();

      calendarStore = new Service.RESTCalendarStore
         (Config.contactStoreUri, Config.receptionStoreUri,
             Config.serverToken, transport);
    });

    tearDown (() {
      calendarStore = null;
      transport.client.close(force : true);
    });

  test ('Contact list',
      () => RESTCalendarStore.existingContactCalendar(calendarStore));

  test ('Reception list',
      () => RESTCalendarStore.existingReceptionCalendar(calendarStore));

  });
}