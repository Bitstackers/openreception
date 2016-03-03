part of openreception_tests.rest;

void _runCalendarTests() {
  group('$_namespace.Calendar', () {
    Logger log = new Logger('$_namespace.Calendar');

    ServiceAgent sa;
    TestEnvironment env;
    process.CalendarServer cProcess;
    process.AuthServer aProcess;
    transport.Client client;
    AuthToken authToken;
    model.BaseContact contact;
    model.Reception reception;
    model.Owner owner;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new transport.Client();
      authToken = new AuthToken(sa.user);
      contact = await sa.createsContact();

      owner = new model.OwningContact(contact.id);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      cProcess =
          new process.CalendarServer(Config.serverStackPath, env.runpath.path);

      sa.calendarStore = new service.RESTCalendarStore(
          Config.calendarStoreUri, authToken.tokenName, client);
      await Future.wait([cProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait([cProcess.terminate(), aProcess.terminate()]);
      env.clear();
      sa.cleanup();
      client.client.close();
    });
    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.Calendar.list(Config.calendarStoreUri, owner), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.calendarStoreUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.calendarStoreUri}/nonexistingpath'
                '?token=${authToken.tokenName}'),
            log));

    test('get (non-existing)',
        () => storeTest.Calendar.getNonExistingEntry(env.calendarStore));

    /**
     * Basic CRUD tests for contact owner.
     */
    test('create (contact owner)',
        () => storeTest.Calendar.create(owner, sa.calendarStore, sa.user));

    test('get (contact owner)',
        () => storeTest.Calendar.get(owner, sa.calendarStore, sa.user));

    test('update (contact owner)',
        () => storeTest.Calendar.update(owner, sa.calendarStore, sa.user));

    test('list (contact owner)',
        () => storeTest.Calendar.list(owner, sa.calendarStore, sa.user));

    test('remove (contact owner)',
        () => storeTest.Calendar.remove(owner, sa.calendarStore, sa.user));

    // test('change listing on create (contact owner)',
    //     () => storeTest.Calendar.changeOnCreate(owner, calendarStore, r.user));
    //
    // test(
    //     'latest change on create (contact owner)',
    //     () => storeTest.Calendar
    //         .latestChangeOnCreate(owner, calendarStore, r.user));
    //
    // test('change listing on update (contact owner)',
    //     () => storeTest.Calendar.changeOnUpdate(owner, calendarStore, r.user));
    //
    // test(
    //     'latest change on update (contact owner)',
    //     () => storeTest.Calendar
    //         .latestChangeOnUpdate(owner, calendarStore, r.user));
    //
    // test('change listing on remove (contact owner)',
    //     () => storeTest.Calendar.changeOnRemove(owner, calendarStore, r.user));
    //
    // test(
    //     'latest change on remove (contact owner)',
    //     () => storeTest.Calendar
    //         .latestChangeOnRemove(owner, calendarStore, r.user));

    /**
                 * Setup/teardown Basic CRUD tests for contact owner.
                 */
    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      await env.receptionStore.ready;

      reception = await sa.createsReception(await sa.createsOrganization());

      owner = new model.OwningContact(reception.id);
    });

    tearDown(() async {
      env.clear();
    });

    /**
                 * Basic CRUD tests for reception owner.
                 */
    test('get (reception owner)',
        () => storeTest.Calendar.get(owner, sa.calendarStore, sa.user));

    test('create (reception owner)',
        () => storeTest.Calendar.create(owner, sa.calendarStore, sa.user));

    test('list (reception owner)',
        () => storeTest.Calendar.list(owner, sa.calendarStore, sa.user));

    test('remove (reception owner)',
        () => storeTest.Calendar.remove(owner, sa.calendarStore, sa.user));

    test('update (reception owner)',
        () => storeTest.Calendar.update(owner, env.calendarStore, sa.user));
    //
    // test('change listing on create (reception owner)',
    //     () => storeTest.Calendar.changeOnCreate(owner, calendarStore, r.user));
    //
    // test(
    //     'latest change on create (reception owner)',
    //     () => storeTest.Calendar
    //         .latestChangeOnCreate(owner, calendarStore, r.user));
    //
    // test('change listing on update (reception owner)',
    //     () => storeTest.Calendar.changeOnUpdate(owner, calendarStore, r.user));
    //
    // test(
    //     'latest change on update (reception owner)',
    //     () => storeTest.Calendar
    //         .latestChangeOnUpdate(owner, sa.calendarStore, sa.user));
    //
    // test(
    //     'change listing on remove (reception owner)',
    //     () => storeTest.Calendar
    //         .changeOnRemove(owner, sa.calendarStore, sa.user));
    //
    // test(
    //     'latest change on remove (reception owner)',
    //     () => storeTest.Calendar
    //         .latestChangeOnRemove(owner, sa.calendarStore, sa.user));
  });
}
