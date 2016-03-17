part of openreception_tests.rest;

void _runAuthServerTests() {
  group('$_namespace.Authentication', () {
    Logger log = new Logger('$_namespace.Authentication');

    ServiceAgent sa;
    TestEnvironment env;
    process.AuthServer aProcess;
    service.Client client;
    AuthToken authToken;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new service.Client();
      authToken = new AuthToken(sa.user);
      sa.authToken = authToken.tokenName;

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken],
          bindAddress: env.envConfig.externalIp,
          servicePort: env.nextNetworkport);

      sa.authService = aProcess.bindClient(client, sa.authToken);
      await aProcess.whenReady;
    });

    tearDown(() async {
      await aProcess.terminate();
      env.clear();
      client.client.close();
    });

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            resource.Authentication.validate(aProcess.uri, ''), log));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${aProcess.uri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () =>
            nonExistingPath(Uri.parse('${aProcess.uri}/nonexistingpath'), log));

    test('Non-existing token',
        () => serviceTest.AuthService.nonExistingToken(sa));

    test('Validate non-existing token',
        () => serviceTest.AuthService.validateNonExistingToken(sa));

    test('Existing token', () => serviceTest.AuthService.existingToken(sa));

    test('Validate existing token',
        () => serviceTest.AuthService.validateExistingToken(sa));
  });
}
