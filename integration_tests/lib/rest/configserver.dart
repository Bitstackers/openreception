part of openreception_tests.service;

void runConfigServerTests() {
  group('RESTConfigService', () {
    transport.Client client = null;
    service.RESTConfiguration configServer;

    setUp(() {
      client = new transport.Client();
    });

    tearDown(() {
      client.client.close(force: true);
    });

    test('CORS headers present',
        () => ConfigService.isCORSHeadersPresent(client.client));

    test('Non-existing path',
        () => ConfigService.nonExistingPath(client.client));

    setUp(() {
      client = new transport.Client();
      configServer =
          new service.RESTConfiguration(Config.configServerUri, client);
    });

    tearDown(() {
      client.client.close(force: true);
      configServer = null;
    });

    test(
        'Get',
        () => configServer
                .clientConfig()
                .then((model.ClientConfiguration configuration) {
              expect(configuration, isNotNull);
              expect(configuration.authServerUri, new isInstanceOf<Uri>());
              expect(configuration.callFlowServerUri, new isInstanceOf<Uri>());
              expect(configuration.contactServerUri, new isInstanceOf<Uri>());
              expect(configuration.messageServerUri, new isInstanceOf<Uri>());
              expect(
                  configuration.notificationSocketUri, new isInstanceOf<Uri>());
              expect(configuration.receptionServerUri, new isInstanceOf<Uri>());
              expect(configuration.systemLanguage, new isInstanceOf<String>());
            }));
  });
}
