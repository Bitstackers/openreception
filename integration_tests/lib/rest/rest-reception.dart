part of openreception_tests.rest;

void _runReceptionTests() {
  group('$_namespace.Reception', () {
    Logger log = new Logger('$_namespace.Reception');

    ServiceAgent sa;
    TestEnvironment env;
    process.ReceptionServer rProcess;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      rProcess = await env.requestReceptionserverProcess();
      sa.receptionStore = rProcess.bindClient(env.httpClient, sa.authToken);
    });

    tearDown(() async {
      env.clear();
    });

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.ReceptionDialplan.list(rProcess.uri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${rProcess.uri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${rProcess.uri}/nonexistingpath'
                '?token=${sa.authToken.tokenName}'),
            log));

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

    test('Reception creation (event presence)',
        () => serviceTest.Reception.createEvent(sa));

    test('Reception update (event presence)',
        () => serviceTest.Reception.updateEvent(sa));

    test('Reception removal (event presence)',
        () => serviceTest.Reception.deleteEvent(sa));

    test('change listing on create',
        () => storeTest.Reception.changeOnCreate(sa));

    test('change listing on update',
        () => storeTest.Reception.changeOnUpdate(sa));

    test('change listing on remove',
        () => storeTest.Reception.changeOnRemove(sa));
  });
}
