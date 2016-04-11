part of openreception_tests.filestore;

void _runReceptionTests() {
  group('$_namespace.Reception', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      await env.receptionStore.ready;
    });

    tearDown(() async {
      env.clear();
    });

    test('create', () => storeTest.Reception.create(sa));
    test('update', () => storeTest.Reception.update(sa));
    test('update (not found)', () => storeTest.Reception.updateNonExisting(sa));
    test('update (invalid)', () => storeTest.Reception.updateInvalid(sa));
    test('remove', () => storeTest.Reception.remove(sa));

    test('extension of', () => storeTest.Reception.extensionOf(sa));
    test('by extension', () => storeTest.Reception.byExtension(sa));

    test('get', () => storeTest.Reception.existingReception(sa));
    test('get (not found)', () => storeTest.Reception.nonExistingReception(sa));
    test('list', () => storeTest.Reception.listReceptions(sa));

    test('change listing on create',
        () => storeTest.Reception.changeOnCreate(sa));

    test('change listing on update',
        () => storeTest.Reception.changeOnUpdate(sa));

    test('change listing on remove',
        () => storeTest.Reception.changeOnRemove(sa));
  });
}
