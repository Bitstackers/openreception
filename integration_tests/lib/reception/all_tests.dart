part of or_test_fw;

runReceptionTests () {

  group ('service.Reception', () {
    Transport.Client transport = null;
    Service.RESTReceptionStore receptionStore = null;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => Reception_Store.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => Reception_Store.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      receptionStore = new Service.RESTReceptionStore
         (Config.receptionStoreURI, Config.serverToken, transport);

    });

    tearDown (() {
      receptionStore = null;
      transport.client.close(force : true);
    });

    test ('Non-existing reception',
        () => Reception_Store.nonExistingReception(receptionStore));
    test ('Existing reception',
        () => Reception_Store.existingReception);
    test ('Calendar listing',
        () => Reception_Store.existingReceptionCalendar(receptionStore));
    test ('Calendar creation',
        () => Reception_Store.calendarEventCreate(receptionStore));
    test ('Calendar update',
        () => Reception_Store.calendarEventUpdate(receptionStore));
    test ('Calendar single',
        () => Reception_Store.calendarEventExisting(receptionStore));
    test ('Calendar single (non-existing)',
        () => Reception_Store.calendarEventNonExisting(receptionStore));
  });
}