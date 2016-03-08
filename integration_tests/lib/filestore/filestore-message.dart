part of openreception_tests.filestore;

_runMessageTests() {
  group('$_namespace.Message', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      await env.messageStore.ready;

      sa = await env.createsServiceAgent();
    });

    tearDown(() async {
      env.clear();
    });

    test('get (not found)', () => storeTest.MessageStore.getNotFound(sa));
    test('get', () => storeTest.MessageStore.get(sa));
    test('list', () => storeTest.MessageStore.list(sa));
    test('list (filtered)', () => storeTest.MessageStore.listFiltered(sa));
    test('create', () => storeTest.MessageStore.create(sa));
    test('update', () => storeTest.MessageStore.update(sa));
    test('remove', () => storeTest.MessageStore.remove(sa));
  });
}
