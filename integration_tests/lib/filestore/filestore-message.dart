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
      await env.clear();
    });

    test('get (not found)', () => storeTest.Message.getNotFound(sa));
    test('get', () => storeTest.Message.get(sa));
    test('list', () => storeTest.Message.list(sa));
    test('list (filtered)', () => storeTest.Message.listFiltered(sa));
    test('create', () => storeTest.Message.create(sa));
    test('update', () => storeTest.Message.update(sa));
    test('remove', () => storeTest.Message.remove(sa));

    test(
        'change listing on create', () => storeTest.Message.changeOnCreate(sa));

    test(
        'change listing on update', () => storeTest.Message.changeOnUpdate(sa));

    test(
        'change listing on remove', () => storeTest.Message.changeOnRemove(sa));
  });
}
