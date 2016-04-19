part of openreception_tests.filestore;

void _runContactTests() {
  group('$_namespace.Contact', () {
    ServiceAgent sa;
    TestEnvironment env;

    setUp(() async {
      env = new TestEnvironment();
      await env.contactStore.ready;
      await env.receptionStore.ready;
      await env.calendarStore.ready;

      sa = await env.createsServiceAgent();
    });

    tearDown(() async {
      await env.clear();
    });

    test('getByReception', () => storeTest.Contact.getByReception(sa));

    test('organizationContacts',
        () => storeTest.Contact.organizationContacts(sa));

    test('organizations', () => storeTest.Contact.organizations(sa));

    test('receptions', () => storeTest.Contact.receptions(sa));

    test('list', () => storeTest.Contact.list(sa));

    test('get', () => storeTest.Contact.get(sa));

    test('BaseContact create', () => storeTest.Contact.create(sa));

    test('BaseContact update', () => storeTest.Contact.update(sa));

    test('BaseContact remove', () => storeTest.Contact.remove(sa));

    test(
        'Non-existing contact', () => storeTest.Contact.nonExistingContact(sa));

    test('List contacts by reception',
        () => storeTest.Contact.listByReception(sa));
    test('List contacts by Non-existing reception',
        () => storeTest.Contact.listContactsByNonExistingReception(sa));

    test('Endpoint listing', () => storeTest.Contact.endpoints(sa));
    test('Endpoint create', () => storeTest.Contact.endpointCreate(sa));
    test('Endpoint update', () => storeTest.Contact.endpointUpdate(sa));
    test('Endpoint remove', () => storeTest.Contact.endpointRemove(sa));

    test('Phone listing', () => storeTest.Contact.phones(sa));

    test('addToReception', () => storeTest.Contact.addToReception(sa));

    test('updateInReception', () => storeTest.Contact.updateInReception(sa));

    test(
        'deleteFromReception', () => storeTest.Contact.deleteFromReception(sa));

    test(
        'change listing on create', () => storeTest.Contact.changeOnCreate(sa));

    test(
        'change listing on update', () => storeTest.Contact.changeOnUpdate(sa));

    test(
        'change listing on remove', () => storeTest.Contact.changeOnRemove(sa));

    test('change listing on reception add',
        () => storeTest.Contact.addToReceptionChange(sa));

    test('change listing on reception update',
        () => storeTest.Contact.updateInReceptionChange(sa));

    test('change listing on reception delete',
        () => storeTest.Contact.deleteFromReceptionChange(sa));
  });
}
