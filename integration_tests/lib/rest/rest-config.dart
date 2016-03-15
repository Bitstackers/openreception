part of openreception_tests.rest;

void runConfigServerTests() {
  group('$_namespace.Config', () {
    Logger log = new Logger('$_namespace.Config');

    ServiceAgent sa;
    TestEnvironment env;
    process.ConfigServer cProcess;
    transport.Client client;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new transport.Client();

      cProcess = new process.ConfigServer(Config.serverStackPath);

      sa.configService =
          new service.RESTConfiguration(Config.configServerUri, client);
      await Future.wait([cProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait([cProcess.terminate()]);
      env.clear();
      client.client.close();
    });
    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.Config.get(Config.configServerUri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.configServerUri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.configServerUri}/nonexistingpath'), log));

    test(
        'Get',
        () => sa.configService
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
