part of or_test_fw;

runContactTests() {
  serviceContactTests();
  serviceEndpoint();
}

void serviceEndpoint() {
  group('Service.RESTEndpointStore', () {
    Transport.Client transport = null;
    Service.RESTEndpointStore endpointStore;

    setUp(() {
      transport = new Transport.Client();
      endpointStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      endpointStore = null;
      transport.client.close(force: true);
    });

    test('list', () => storeTest.Contact.endpoints(endpointStore));

    test('create', () => storeTest.Contact.endpointCreate(endpointStore));

    test('remove', () => storeTest.Contact.endpointRemove(endpointStore));

    test('update', () => storeTest.Contact.endpointUpdate(endpointStore));
  });
}

void serviceContactTests() {
  var _log = new Logger('tmp');
  /**
   * Test for the presence of CORS headers.
   */
  Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.contactStoreUri}/nonexistingpath');

    _log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.headers['access-control-allow-origin'] == null &&
                  response.headers['Access-Control-Allow-Origin'] == null) {
                fail('No CORS headers on path $uri');
              }
            }))
        .then((_) {
      _log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.contactStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) =>
          request.close().then((HttpClientResponse response) {
            if (response.headers['access-control-allow-origin'] == null &&
                response.headers['Access-Control-Allow-Origin'] == null) {
              fail('No CORS headers on path $uri');
            }
          }));
    });
  }

  /**
   * Test server behaviour when trying to access a resource not associated with
   * a handler.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  Future nonExistingPath(HttpClient client) {
    Uri uri = Uri.parse(
        '${Config.contactStoreUri}/nonexistingpath?token=${Config.serverToken}');

    _log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.statusCode != 404) {
                fail('Expected to received a 404 on path $uri');
              }
            }))
        .then((_) => _log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  group('RESTContactStore', () {
    Transport.Client transport = null;
    Service.RESTEndpointStore endpointStore;

    Service.RESTContactStore contactStore;

    setUp(() {
      transport = new Transport.Client();
    });

    tearDown(() {
      transport.client.close(force: true);
    });

    test('CORS headers present',
        () => ContactStore.isCORSHeadersPresent(transport.client));

    test('Non-existing path',
        () => ContactStore.nonExistingPath(transport.client));

    setUp(() {
      transport = new Transport.Client();
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, Config.serverToken, transport);

      endpointStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      contactStore = null;
      endpointStore = null;
      transport.client.close(force: true);
    });
    test(
        'getByReception', () => storeTest.Contact.getByReception(contactStore));

    test('organizationContacts',
        () => storeTest.Contact.organizationContacts(contactStore));

    test('organizations', () => storeTest.Contact.organizations(contactStore));

    test('organizations', () => storeTest.Contact.organizations(contactStore));

    test('receptions', () => storeTest.Contact.receptions(contactStore));

    test('list', () => storeTest.Contact.list(contactStore));

    test('get', () => storeTest.Contact.get(contactStore));

    test('BaseContact create', () => storeTest.Contact.create(contactStore));

    test('BaseContact update', () => storeTest.Contact.update(contactStore));

    test('BaseContact remove', () => storeTest.Contact.remove(contactStore));

    test('Non-existing contact',
        () => ContactStore.nonExistingContact(contactStore));
    test('List contacts by reception',
        () => ContactStore.listByReception(contactStore));
    test('List contacts by Non-existing reception',
        () => ContactStore.listContactsByNonExistingReception(contactStore));

    setUp(() {
      transport = new Transport.Client();
      contactStore = new Service.RESTContactStore(
          Config.contactStoreUri, Config.serverToken, transport);

      endpointStore = new Service.RESTEndpointStore(
          Config.contactStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      contactStore = null;
      endpointStore = null;
      transport.client.close(force: true);
    });

    test('Endpoint listing', () => storeTest.Contact.endpoints(endpointStore));

    test('Phone listing', () => storeTest.Contact.phones(contactStore));

    test(
        'addToReception', () => storeTest.Contact.addToReception(contactStore));

    test('updateInReception',
        () => storeTest.Contact.updateInReception(contactStore));

    test('deleteFromReception',
        () => storeTest.Contact.deleteFromReception(contactStore));
  });
}
