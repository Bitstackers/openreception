part of openreception_tests.service;

abstract class AuthService {
  static final Logger log = new Logger('$_namespace.AuthService');

  /**
   * Test for the presence of CORS headers.
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
      uri = resource.Reception.single(Config.authenticationServerUri, 1);
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
  static Future nonExistingToken(ServiceAgent sa) async {
    const badToken = 'nocandosir';

    log.info('Checking server behaviour on a non-existing token.');

    await expect(sa.authService.userOf(badToken),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a user object from a token
   * that exists.
   *
   * The expected behaviour is that the server should return a User object.
   */
  static Future existingToken(ServiceAgent sa) async {
    log.info('Checking server behaviour on a non-existing token.');

    final model.User user = await sa.authService.userOf(sa.authToken);
    expect(user.id, equals(sa.user.id));
    expect(user.name, sa.user.name);
    expect(user.address, sa.user.address);
    expect(user.peer, sa.user.peer);
    expect(user.enabled, sa.user.enabled);
    expect(user.groups, sa.user.groups);
    expect(user.identities, sa.user.identities);

    log.info('Test complete');
  }

  /**
   * Test server behaviour when trying to validae a token that does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future validateNonExistingToken(ServiceAgent sa) async {
    const badToken = 'nocandosir';

    log.info('Checking server behaviour on a non-existing token.');

    await expect(sa.authService.userOf(badToken),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to validate a token that exists.
   *
   * The expected behaviour is that the server should normally.
   */
  static Future validateExistingToken(ServiceAgent sa) async {
    log.info('Checking server behaviour on a non-existing token.');

    await sa.authService.userOf(sa.authToken);
  }
}
