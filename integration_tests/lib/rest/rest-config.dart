part of openreception_tests.rest;

void _runConfigTests() {
  group('$_namespace.Config', () {
    Logger log = new Logger('$_namespace.Config');

    ServiceAgent sa;
    TestEnvironment env;
    process.ConfigServer cProcess;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      cProcess = await env.requestConfigServerProcess();

      sa.configService = cProcess.createClient(env.httpClient);
      await Future.wait([cProcess.whenReady]);
    });

    tearDown(() async {
      env.clear();
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
