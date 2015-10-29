part of or_test_fw;

/**
 * TODO: Add test for get-reception-by-extension.
 */
runReceptionTests () {

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

  group ('service.Reception', () {
    Transport.Client transport = null;
    Service.RESTReceptionStore receptionStore = null;
    Receptionist r;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => Reception.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => Reception.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      receptionStore = new Service.RESTReceptionStore
         (Config.receptionStoreUri, Config.serverToken, transport);

    });

    tearDown (() {
      receptionStore = null;
      transport.client.close(force : true);
    });

    test ('Non-existing reception',
        () => Reception.nonExistingReception(receptionStore));

    test ('Existing reception',
        () => Reception.existingReception(receptionStore));

    test ('List receptions',
        () => Reception.listReceptions(receptionStore));

    test ('Calendar event listing',
        () => Reception.existingReceptionCalendar(receptionStore));

    test ('Calendar event creation',
        () => Reception.calendarEventCreate(receptionStore));

    test ('Calendar event update',
        () => Reception.calendarEventUpdate(receptionStore));

    test ('Calendar event',
        () => Reception.calendarEventExisting(receptionStore));

    test ('Calendar event (non-existing)',
        () => Reception.calendarEventNonExisting(receptionStore));

    test ('Calendar event removal',
        () => Reception.calendarEventDelete(receptionStore));

    test ('Calendar event changes (create)',
        () => Reception.calendarEntryChangeCreate(receptionStore));

    test ('Calendar event changes (update)',
        () => Reception.calendarEntryChangeUpdate(receptionStore));

    test ('Calendar event changes (delete)',
        () => Reception.calendarEntryChangeDelete(receptionStore));

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

    test ('Lookup by extension',
        () => Reception.byExtension(receptionStore));

    test ('Lookup extension',
        () => Reception.extensionOf(receptionStore));

    setUp (() {
      transport = new Transport.Client();
      receptionStore = new Service.RESTReceptionStore
         (Config.receptionStoreUri, Config.serverToken, transport);
      r = ReceptionistPool.instance.aquire();

      return r.initialize();
    });

    tearDown (() {
      receptionStore = null;
      transport.client.close(force : true);

      ReceptionistPool.instance.release(r);

      return r.teardown();
    });

    test ('CalendarEntry creation (event presence)',
        () => Reception.calendarEntryCreateEvent(receptionStore, r));

    test ('CalendarEntry update (event presence)',
        () => Reception.calendarEntryUpdateEvent(receptionStore, r));

    test ('CalendarEntry creation (event presence)',
        () => Reception.calendarEntryDeleteEvent(receptionStore, r));

    test ('Reception creation (event presence)',
        () => Reception.createEvent(receptionStore, r));

    test ('Reception update (event presence)',
        () => Reception.updateEvent(receptionStore, r));

    test ('Reception removal (event presence)',
        () => Reception.deleteEvent(receptionStore, r));
  });
}