part of openreception_tests.filestore;

void _runIvrTests() {
  group('$_namespace.Ivr', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      await env.ivrStore.ready;
    });

    tearDown(() async {
      env.clear();
    });

    test('create', () => storeTest.Ivr.create(env.ivrStore, sa.user));

    test('get', () => storeTest.Ivr.get(env.ivrStore, sa.user));

    test('list', () => storeTest.Ivr.list(env.ivrStore, sa.user));

    test('remove', () => storeTest.Ivr.remove(env.ivrStore, sa.user));

    test('update', () => storeTest.Ivr.update(env.ivrStore, sa.user));

    test('change listing on create', () => storeTest.Ivr.changeOnCreate(sa));

    test('change listing on update', () => storeTest.Ivr.changeOnUpdate(sa));

    test('change listing on remove', () => storeTest.Ivr.changeOnRemove(sa));
  });
}
