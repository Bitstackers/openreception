part of or_test_fw;

void runConfigServerTests() {
  group('RESTConfigService', () {
    Transport.Client transport = null;
    Service.RESTConfiguration configServer;

    setUp(() {
      transport = new Transport.Client();
    });

    tearDown(() {
      transport.client.close(force: true);
    });

    test('CORS headers present',
        () => ConfigService.isCORSHeadersPresent(transport.client));

    test('Non-existing path',
        () => ConfigService.nonExistingPath(transport.client));

    setUp(() {
      transport = new Transport.Client();
      configServer =
          new Service.RESTConfiguration(Config.configServerUri, transport);
    });

    tearDown(() {
      transport.client.close(force: true);
      configServer = null;
    });

    test('Get', () => configServer
        .clientConfig()
        .then((Model.ClientConfiguration configuration) {
      expect(configuration, isNotNull);
      expect(configuration.authServerUri, new isInstanceOf<Uri>());
      expect(configuration.callFlowServerUri, new isInstanceOf<Uri>());
      expect(configuration.contactServerUri, new isInstanceOf<Uri>());
      expect(configuration.messageServerUri, new isInstanceOf<Uri>());
      expect(configuration.notificationSocketUri, new isInstanceOf<Uri>());
      expect(configuration.receptionServerUri, new isInstanceOf<Uri>());
      expect(configuration.systemLanguage, new isInstanceOf<String>());      
    }));
  });
}
