part of openreception_tests.filestore;

_runUserTests() {
  group('$_namespace.User', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      await env.contactStore.ready;
      await env.receptionStore.ready;
      await env.userStore.ready;

      sa = await env.createsServiceAgent();
    });

    tearDown(() async {
      env.clear();
    });

    test('get', () => storeTest.User.existing(sa));

    test('get (not found)', () => storeTest.User.nonExisting(sa));

    test('create', () => storeTest.User.create(sa));

    test('update', () => storeTest.User.update(sa));

    test('remove', () => storeTest.User.update(sa));

    test('list', () => storeTest.User.list(sa));

    test('groups', () => storeTest.User.listAllGroups(sa));

    test('groups of (known user)', () => storeTest.User.userGroups(sa));

    test('group join', () => storeTest.User.joinGroup(sa));

    test('group leave', () => storeTest.User.leaveGroup(sa));

    test('identity add', () => storeTest.User.addUserIdentity(sa));

    test('identity remove', () => storeTest.User.removeUserIdentity(sa));

    test('get (by identity)', () => storeTest.User.getUserByIdentity(sa));
  });
}
