part of openreception_tests.filestore;

void _runCalendarTests() {
  group('$_namespace.Calendar', () {
    ServiceAgent sa;
    TestEnvironment env;
    model.BaseContact contact;
    model.Reception reception;
    model.Owner owner;

    /**
     * Setup/teardown Basic CRUD tests for contact owner.
     */
    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      await sa.contactStore.ready;
      await sa.calendarStore.ready;

      contact = await sa.createsContact();

      owner = new model.OwningContact(contact.id);
    });

    tearDown(() async {
      env.clear();
    });

    test('get (non-existing)',
        () => storeTest.Calendar.getNonExistingEntry(env.calendarStore));

    /**
     * Basic CRUD tests for contact owner.
     */
    test('create (contact owner)',
        () => storeTest.Calendar.create(owner, env.calendarStore, sa.user));

    test('get (contact owner)',
        () => storeTest.Calendar.get(owner, env.calendarStore, sa.user));

    test('update (contact owner)',
        () => storeTest.Calendar.update(owner, env.calendarStore, sa.user));

    test('list (contact owner)',
        () => storeTest.Calendar.list(owner, env.calendarStore, sa.user));

    test('remove (contact owner)',
        () => storeTest.Calendar.remove(owner, env.calendarStore, sa.user));

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
        () => storeTest.Calendar.get(owner, env.calendarStore, sa.user));

    test('create (reception owner)',
        () => storeTest.Calendar.create(owner, env.calendarStore, sa.user));

    test('list (reception owner)',
        () => storeTest.Calendar.list(owner, env.calendarStore, sa.user));

    test('remove (reception owner)',
        () => storeTest.Calendar.remove(owner, env.calendarStore, sa.user));

    test('update (reception owner)',
        () => storeTest.Calendar.update(owner, env.calendarStore, sa.user));
  });
}
