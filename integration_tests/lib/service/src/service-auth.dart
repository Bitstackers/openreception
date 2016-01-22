part of or_test_fw;

abstract class AuthService {
  static final Logger log = new Logger('$libraryName.AuthService');

  /**
   * Test for the presence of CORS headers.
   * TODO: Refactor this to use the library-level function.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.authenticationServerUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
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
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.authenticationServerUri, 1);
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
  static Future nonExistingPath(HttpClient client) {
    Uri uri = Uri.parse('${Config.authenticationServerUri}/nonexistingpath');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.statusCode != 404) {
                fail('Expected to received a 404 on path $uri');
              }
            }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a user object from a token that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future nonExistingToken(Service.Authentication authService) async {
    const badToken = 'nocandosir';

    log.info('Checking server behaviour on a non-existing token.');

    await expect(authService.userOf(badToken),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a user object from a token
   * that exists.
   *
   * The expected behaviour is that the server should return a User object.
   */
  static Future existingToken(
      Service.Authentication authService, Receptionist receptionist) async {
    log.info('Checking server behaviour on a non-existing token.');

    final Model.User user = await authService.userOf(receptionist.authToken);
    expect(user.ID, equals(receptionist.user.ID));
    expect(user.name, isNotEmpty);
    expect(user.address, isNotNull);
    expect(user.groups, isNotEmpty);
    expect(user.peer, isNotEmpty);
    log.info('Test complete');
  }

  /**
   * Test server behaviour when trying to validae a token that does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future validateNonExistingToken(
      Service.Authentication authService) async {
    const badToken = 'nocandosir';

    log.info('Checking server behaviour on a non-existing token.');

    await expect(authService.userOf(badToken),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to validate a token that exists.
   *
   * The expected behaviour is that the server should normally.
   */
  static Future validateExistingToken(
      Service.Authentication authService, Receptionist receptionist) async {
    log.info('Checking server behaviour on a non-existing token.');

    await authService.userOf(receptionist.authToken);
  }
}
