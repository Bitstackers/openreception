part of or_test_fw;

runReceptionTests () {

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
        () => ReceptionStore.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => ReceptionStore.nonExistingPath(transport.client));

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
        () => ReceptionStore.nonExistingReception(receptionStore));
    test ('Existing reception',
        () => ReceptionStore.existingReception(receptionStore));
    test ('List receptions',
        () => ReceptionStore.listReceptions(receptionStore));

    test ('Calendar event listing',
        () => ReceptionStore.existingReceptionCalendar(receptionStore));
    test ('Calendar event creation',
        () => ReceptionStore.calendarEventCreate(receptionStore));
    test ('Calendar event update',
        () => ReceptionStore.calendarEventUpdate(receptionStore));
    test ('Calendar event',
        () => ReceptionStore.calendarEventExisting(receptionStore));
    test ('Calendar event (non-existing)',
        () => ReceptionStore.calendarEventNonExisting(receptionStore));
    test ('Calendar event removal',
        () => ReceptionStore.calendarEventDelete(receptionStore));


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


      return r.teardown();
    });

    test ('CalendarEntry creation (event presence)',
        () => ReceptionStore.calendarEntryCreateEvent(receptionStore, r));

    test ('CalendarEntry update (event presence)',
        () => ReceptionStore.calendarEntryUpdateEvent(receptionStore, r));

    test ('CalendarEntry creation (event presence)',
        () => ReceptionStore.calendarEntryDeleteEvent(receptionStore, r));
  });
}