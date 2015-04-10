part of or_test_fw;

void runAuthServerTests() {
  group ('RESTAuthService', () {
    Transport.Client transport = null;
    Service.Authentication authService = null;
    Receptionist receptionist;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => AuthService.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => AuthService.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      authService = new Service.Authentication
         (Config.authenticationServerUri, Config.serverToken, transport);
      receptionist = ReceptionistPool.instance.aquire();

      return receptionist.ready();
    });

    tearDown (() {
      authService = null;
      transport.client.close(force : true);
      ReceptionistPool.instance.release(receptionist);

      return receptionist.teardown();
    });

    test ('Non-existing token',
        () => AuthService.nonExistingToken(authService));

    test ('Existing token',
        () => AuthService.existingToken(authService, receptionist));
  });
}

