part of openreception_tests.rest;

void _runConfigTests() {
  group('$_namespace.Config', () {
    Logger log = new Logger('$_namespace.Config');

    ServiceAgent sa;
    TestEnvironment env;
    process.ConfigServer cProcess;
    service.Client client;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new service.Client();

      cProcess = new process.ConfigServer(Config.serverStackPath,
          servicePort: env.nextNetworkport,
          bindAddress: env.envConfig.externalIp);

      sa.configService = cProcess.createClient(client);
      await Future.wait([cProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait([cProcess.terminate()]);
      env.clear();
      client.client.close();
    });

    test('CORS headers present (existingUri)',
        () => isCORSHeadersPresent(resource.Config.get(cProcess.uri), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${cProcess.uri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () =>
            nonExistingPath(Uri.parse('${cProcess.uri}/nonexistingpath'), log));

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
