part of openreception_tests.service;

void runAuthServerTests() {
  group('RESTAuthService', () {
    transport.Client client = null;
    service.Authentication authService = null;
    Receptionist receptionist;

    setUp(() {
      client = new transport.Client();
    });

    tearDown(() {
      client.client.close(force: true);
    });

    test('CORS headers present',
        () => AuthService.isCORSHeadersPresent(client.client));

    test('Non-existing path', () => AuthService.nonExistingPath(client.client));

    setUp(() {
      client = new transport.Client();
      authService = new service.Authentication(
          Config.authenticationServerUri, Config.serverToken, client);
    });

    tearDown(() {
      authService = null;
      client.client.close(force: true);
    });

    test('Non-existing token', () => AuthService.nonExistingToken(authService));

    test('Validate non-existing token',
        () => AuthService.validateNonExistingToken(authService));

    setUp(() {
      client = new transport.Client();
      authService = new service.Authentication(
          Config.authenticationServerUri, Config.serverToken, client);
      receptionist = ReceptionistPool.instance.aquire();

      return receptionist.initialize();
    });

    tearDown(() {
      authService = null;
      client.client.close(force: true);
      ReceptionistPool.instance.release(receptionist);

      return receptionist.teardown();
    });

    test('Existing token',
        () => AuthService.existingToken(authService, receptionist));

    test('Validate existing token',
        () => AuthService.validateExistingToken(authService, receptionist));
  });
}
