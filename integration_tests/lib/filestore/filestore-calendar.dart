part of openreception_tests.filestore;

void _runCalendarTests() {
  group('$_namespace.Calendar', () {
    ServiceAgent sa;
    TestEnvironment env;
    model.Owner owner;

    setUp(() async {
      env = new TestEnvironment();

      sa = await env.createsServiceAgent();
      owner = new model.OwningContact((await sa.createsContact()).id);
    });

    tearDown(() async {
      await env.clear();
    });

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

    /**
     * Setup/teardown Basic CRUD tests for contact owner.
     */
    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      await env.receptionStore.ready;

      final reception =
          await sa.createsReception(await sa.createsOrganization());

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
