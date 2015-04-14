part of or_test_fw;

void runConfigServerTests() {
  group ('RESTConfigService', () {
    Transport.Client transport = null;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => ConfigService.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => ConfigService.nonExistingPath(transport.client));
  });
}

