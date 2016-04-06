part of openreception_tests.rest;

void _runCalendarTests() {
  group('$_namespace.Calendar', () {
    Logger log = new Logger('$_namespace.Calendar');

    ServiceAgent sa;
    TestEnvironment env;
    process.CalendarServer cProcess;
    model.BaseContact contact;
    model.Reception reception;
    model.Owner owner;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      contact = await sa.createsContact();

      owner = new model.OwningContact(contact.id);

      cProcess = await env.requestCalendarserverProcess();

      sa.calendarStore = cProcess.bindClient(env.httpClient, sa.authToken);
    });

    tearDown(() async {
      await env.clear();
    });

    test(
        'CORS headers present (existingUri)',
        () async => isCORSHeadersPresent(
            resource.Calendar
                .list((await env.requestCalendarserverProcess()).uri, owner),
            log));

    test(
        'CORS headers present (non-existingUri)',
        () async => isCORSHeadersPresent(
            Uri.parse(
                '${(await env.requestCalendarserverProcess()).uri}/nonexistingpath'),
            log));

    test(
        'Non-existing path',
        () async => nonExistingPath(
            Uri.parse(
                '${(await env.requestCalendarserverProcess()).uri}/nonexistingpath'
                '?token=${sa.authToken.tokenName}'),
            log));

    test(
        'get (non-existing)', () => storeTest.Calendar.getNonExistingEntry(sa));

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

    test(
        'change listing on create (contact owner)',
        () => storeTest.Calendar
            .changeOnCreate(owner, sa.calendarStore, sa.user));

    test(
        'latest change on create (contact owner)',
        () => storeTest.Calendar
            .latestChangeOnCreate(owner, sa.calendarStore, sa.user));

    test(
        'change listing on update (contact owner)',
        () => storeTest.Calendar
            .changeOnUpdate(owner, sa.calendarStore, sa.user));

    test(
        'latest change on update (contact owner)',
        () => storeTest.Calendar
            .latestChangeOnUpdate(owner, sa.calendarStore, sa.user));

    test(
        'change listing on remove (contact owner)',
        () => storeTest.Calendar
            .changeOnRemove(owner, sa.calendarStore, sa.user));

    test(
        'latest change on remove (contact owner)',
        () => storeTest.Calendar
            .latestChangeOnRemove(owner, sa.calendarStore, sa.user));

    test('create (event presence)',
        () => serviceTest.Calendar.createEvent(sa, owner));

    test('update (event presence)',
        () => serviceTest.Calendar.updateEvent(sa, owner));

    test('remove (event presence)',
        () => serviceTest.Calendar.deleteEvent(sa, owner));

    /**
     * Setup/teardown Basic CRUD tests for contact owner.
     */
    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      await env.receptionStore.ready;

      reception = await sa.createsReception(await sa.createsOrganization());

      owner = new model.OwningContact(reception.id);

      cProcess = await env.requestCalendarserverProcess();

      sa.calendarStore = cProcess.bindClient(env.httpClient, sa.authToken);
    });

    tearDown(() async {
      await env.clear();
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
        () => storeTest.Calendar.update(owner, sa.calendarStore, sa.user));

    test(
        'change listing on create (reception owner)',
        () => storeTest.Calendar
            .changeOnCreate(owner, sa.calendarStore, sa.user));

    test(
        'latest change on create (reception owner)',
        () => storeTest.Calendar
            .latestChangeOnCreate(owner, sa.calendarStore, sa.user));

    test(
        'change listing on update (reception owner)',
        () => storeTest.Calendar
            .changeOnUpdate(owner, sa.calendarStore, sa.user));

    test(
        'latest change on update (reception owner)',
        () => storeTest.Calendar
            .latestChangeOnUpdate(owner, sa.calendarStore, sa.user));

    test(
        'change listing on remove (reception owner)',
        () => storeTest.Calendar
            .changeOnRemove(owner, sa.calendarStore, sa.user));

    test(
        'latest change on remove (reception owner)',
        () => storeTest.Calendar
            .latestChangeOnRemove(owner, sa.calendarStore, sa.user));
  });
}
