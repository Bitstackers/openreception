part of or_test_fw;

/**
 * Test for the presence of CORS headers.
 */
Future isCORSHeadersPresent(Uri uri) async {
  final HttpClient client = new HttpClient();

  void checkHeaders(HttpClientResponse response) {
    if (response.headers['access-control-allow-origin'] == null &&
        response.headers['Access-Control-Allow-Origin'] == null) {
      fail('No CORS headers on path existingUri');
    }
  }

  Logger.root.info('Checking CORS headers on URI $uri.');

  return client
      .getUrl(uri)
      .then((HttpClientRequest request) => request.close().then(checkHeaders))
      .whenComplete(() => client.close(force: true));
}

/**
 * Test server behaviour when trying to access a resource not associated with
 * a handler.
 *
 * The expected behaviour is that the server should return a Not Found error.
 */
Future nonExistingPath(Uri uri) async {
  final HttpClient client = new HttpClient();

  Logger.root.info('Checking server behaviour on a non-existing path.');

  void checkResponseCode(HttpClientResponse response) {
    if (response.statusCode != 404) {
      fail('Expected to received a 404 on path $uri');
    }
  }

  return client
      .getUrl(uri)
      .then((HttpClientRequest request) =>
          request.close().then(checkResponseCode))
      .then((_) => Logger.root.info('Got expected status code 404.'))
      .whenComplete(() => client.close(force: true));
}

runIvrTests() {
  group('Service.Ivr', () {
    Transport.Client transport = null;
    Service.RESTIvrStore ivrStore = null;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            Resource.ReceptionDialplan.list(Config.dialplanStoreUri)));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath')));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'
                '?token=${Config.serverToken}')));
    setUp(() {
      transport = new Transport.Client();
      ivrStore = new Service.RESTIvrStore(
          Config.dialplanStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      ivrStore = null;
      transport.client.close(force: true);
    });

    test('create', () => storeTest.Ivr.create(ivrStore));

    test('get', () => storeTest.Ivr.get(ivrStore));

    test('list', () => storeTest.Ivr.list(ivrStore));

    test('remove', () => storeTest.Ivr.remove(ivrStore));

    test('update', () => storeTest.Ivr.update(ivrStore));
  });
}
