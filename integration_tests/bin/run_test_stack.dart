import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;

import 'package:logging/logging.dart';
import 'package:openreception.client_app_server/router.dart' as app_router;
import 'package:openreception.framework/keys.dart' as key;
import 'package:openreception_tests/support.dart';
//import 'package:args/args.dart';

/**
 * Logs [record] to STDOUT | STDERR depending on [record] level.
 */
void logEntryDispatch(LogRecord record) {
  final String error = '${record.error != null
      ? ' - ${record.error}'
      : ''}'
      '${record.stackTrace != null
        ? ' - ${record.stackTrace}'
        : ''}';

  if (record.level.value > Level.INFO.value) {
    stderr.writeln('${record.time} - ${record}$error');
  } else {
    stdout.writeln('${record.time} - ${record}$error');
  }
}

Future main(args) async {
  Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  /**
   * Returns a random element from [pool].
   */
  dynamic randomChoice(List pool) {
    if (pool.isEmpty) {
      throw new ArgumentError('Cannot find a random value in an empty list');
    }

    int index = rand.nextInt(pool.length);

    return pool[index];
  }

  Stopwatch timer = new Stopwatch()..start();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(logEntryDispatch);

  // final ArgParser parser = new ArgParser()
  //   ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
  //   ..addOption('filestore', abbr: 'f', help: 'Path to the filestore')
  //   ..addFlag('reuse-store', negatable: false);
  // final ArgResults parsedArgs = parser.parse(args);

  // final Directory fsDir = new Directory(parsedArgs['filestore']);
  // if (fsDir.existsSync() && !parsedArgs['reuse-store']) {
  //   print(
  //       'Filestore path already exist. Please supply a non-existing path or use the --reuse-store flag.');
  //   print(parser.usage);
  //   exit(1);
  // }

  final TestEnvironmentConfig envConfig = new TestEnvironment().envConfig;
  await envConfig.load();
  TestEnvironment env = new TestEnvironment();
  ServiceAgent sa = await env.createsServiceAgent();

  List orgs = new List(10).map((_) async => sa.createsOrganization()).toList();

  List recs = new List(20)
      .map((_) async => sa.createsReception(await randomChoice(orgs)))
      .toList();

  List rCons = new List(40)
      .map((_) async => sa.addsContactToReception(
          await sa.createsContact(), await randomChoice(recs)))
      .toList();

  List rdps = new List(10)
      .map((_) async => await sa.createsDialplan(mustBeValid: true));

  List ivrs = new List(10).map((_) async => await sa.createsIvrMenu());

  final authserver = env.requestAuthserverProcess();
  final notificationserver = env.requestNotificationserverProcess();
  await env.requestFreeswitchProcess();
  final callflow = env.requestCallFlowProcess();
  final dialplanserver = env.requestDialplanProcess();
  final calendarserver = env.requestCalendarserverProcess();
  final contactserver = env.requestContactserverProcess();
  final messageserver = env.requestMessageserverProcess();
  final receptionserver = env.requestReceptionserverProcess();
  final userserver = env.requestUserserverProcess();
  final configserver = env.requestConfigServerProcess();
  final configClient = (await configserver).createClient(env.httpClient);

  configClient.register(key.authentication, (await authserver).uri);
  configClient.register(key.calendar, (await calendarserver).uri);
  configClient.register(key.callflow, (await callflow).uri);
  //configClient.register(key.cdr, cdrserver.uri);
  configClient.register(key.contact, (await contactserver).uri);
  configClient.register(key.dialplan, (await dialplanserver).uri);
  configClient.register(key.message, (await messageserver).uri);
  configClient.register(key.notification, (await notificationserver).uri);
  configClient.register(
      key.notificationSocket, (await notificationserver).notifyUri);
  configClient.register(key.user, (await userserver).uri);
  configClient.register(key.reception, (await receptionserver).uri);

  final clientConfig = await configClient.clientConfig();
  final JsonEncoder jsonpp = new JsonEncoder.withIndent('  ');

  print("Client config:");
  print(jsonpp.convert(clientConfig));
  print("Config server is reachable on ${(await configserver).uri}");
  print("Stack is accessible by using tokens:");
  print('  ' + (await authserver).tokenDir.tokens.join('\n  '));

  timer.stop();
  print('Stack startup time: ${timer.elapsedMilliseconds}ms');

  app_router.FileRouter appRouter = new app_router.FileRouter();

  {
    final int port = env.nextNetworkport;
    final String host = env.envConfig.externalIp;

    appRouter.start(
        host: host, port: port, webroot: '../management_client/web');
    print('Management client (Dartium only) is reachable on '
        'http://$host:$port?config_server=${(await configserver).uri}'
        '&settoken=${(await authserver).tokenDir.tokens.last}');
  }

  {
    final int port = env.nextNetworkport;
    final String host = env.envConfig.externalIp;

    appRouter.start(
        host: host, port: port, webroot: '../receptionist_client/web');
    print('Receptionist client (Dartium only) is reachable on '
        'http://$host:$port?config_server=${(await configserver).uri}'
        '&settoken=${(await authserver).tokenDir.tokens.last}');
  }

  ProcessSignal.SIGINT.watch().listen((_) async {
    final teardownTimer = new Stopwatch()..start();
    await env.clear();
    await env.finalize();
    teardownTimer.stop();
    print('Stack shutdown time: ${teardownTimer.elapsedMilliseconds}ms');
    exit(0);
  });
}
