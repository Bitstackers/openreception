part of openreception_tests.filestore;

void _runDialplanTests() {
  group('$_namespace.ReceptionDialplan', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      await env.dialplanStore.ready;
    });

    tearDown(() async {
      env.clear();
    });

    test('create',
        () => storeTest.ReceptionDialplan.create(env.dialplanStore, sa.user));

    test('get',
        () => storeTest.ReceptionDialplan.get(env.dialplanStore, sa.user));

    test('list',
        () => storeTest.ReceptionDialplan.list(env.dialplanStore, sa.user));

    test('remove',
        () => storeTest.ReceptionDialplan.remove(env.dialplanStore, sa.user));

    test('update',
        () => storeTest.ReceptionDialplan.update(env.dialplanStore, sa.user));
  });
}
