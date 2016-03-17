part of openreception_tests.rest;

void runMessageTests() {
  group('$_namespace.Message', () {
    Logger log = new Logger('$_namespace.Message');

    ServiceAgent sa;
    TestEnvironment env;
    process.MessageServer mProcess;
    process.AuthServer aProcess;
    process.NotificationServer nProcess;
    service.Client client;
    AuthToken authToken;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();
      client = new service.Client();
      authToken = new AuthToken(sa.user);
      sa.authToken = authToken.tokenName;

      nProcess = new process.NotificationServer(
          Config.serverStackPath, env.runpath.path);

      aProcess = new process.AuthServer(
          Config.serverStackPath, env.runpath.path,
          intialTokens: [authToken]);

      mProcess = new process.MessageServer(
          Config.serverStackPath, env.runpath.path,
          bindAddress: env.envConfig.externalIp,
          servicePort: env.nextNetworkport);

      sa.messageStore = mProcess.bindClient(client, sa.authToken);
      await Future
          .wait([nProcess.whenReady, mProcess.whenReady, aProcess.whenReady]);
    });

    tearDown(() async {
      await Future.wait(
          [mProcess.terminate(), aProcess.terminate(), nProcess.terminate()]);
      env.clear();
      client.client.close();
    });
    //
    // test('CORS headers present (existingUri)',
    //     () => isCORSHeadersPresent(resource.Message.list(mProcess.uri), log));
    //
    // test(
    //     'CORS headers present (non-existingUri)',
    //     () => isCORSHeadersPresent(
    //         Uri.parse('${mProcess.uri}/nonexistingpath'), log));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${mProcess.uri}/nonexistingpath'
                '?token=${authToken.tokenName}'),
            log));

    // test('message listing (non-filtered)',
    //     () => storeTest.MessageStore.list(sa));
    //
    // test('message (non-existing ID)',
    //     () => serviceTest.Message.nonExistingMessage(messageStore));
    //
    // test('get', () => storeTest.MessageStore.get(messageStore));
    //
    // test('list', () => storeTest.MessageStore.list(messageStore));
    //
    // tearDown(() {
    //   messageStore = null;
    //   receptionStore = null;
    //   contactStore = null;
    //   client.client.close(force: true);
    //
    //   ReceptionistPool.instance.release(r);
    //   return r.teardown();
    // });
    //
    // setUp(() {
    //   client = new service.Client();
    //   r = ReceptionistPool.instance.aquire();
    //
    //   messageStore = new service.RESTMessageStore(
    //       Config.messageStoreUri, r.authToken, client);
    //   receptionStore = new service.RESTReceptionStore(
    //       Config.receptionStoreUri, r.authToken, client);
    //   contactStore = new service.RESTContactStore(
    //       Config.contactStoreUri, r.authToken, client);
    //
    //   return r.initialize();
    // });
    //
    // test(
    //     'create',
    //     () => MessageStore.create(
    //         messageStore, contactStore, receptionStore, null, null, r));
    //
    // test(
    //     'update',
    //     () => MessageStore.update(
    //         messageStore, contactStore, receptionStore, null, null, r));
    //
    // test(
    //     'enqueue',
    //     () => MessageStore.enqueue(
    //         messageStore, contactStore, receptionStore, null, null, r));
    //
    // test(
    //     'remove',
    //     () => MessageStore.remove(
    //         messageStore, contactStore, receptionStore, null, null, r));
    //
    // test(
    //     'message enqueue (event presence)',
    //     () => RESTMessageStore.messageEnqueueEvent(
    //         messageStore, contactStore, receptionStore, null, null, r));
    //
    // test(
    //     'message update (event presence)',
    //     () => RESTMessageStore.messageUpdateEvent(
    //         messageStore, contactStore, receptionStore, null, null, r));
    //
    // test(
    //     'message create (event presence)',
    //     () => RESTMessageStore.messageCreateEvent(
    //         messageStore, contactStore, receptionStore, null, null, r));
  });
}
