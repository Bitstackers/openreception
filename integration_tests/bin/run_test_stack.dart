import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  List orgs = [];
  await Future.forEach(new List(10), (_) async {
    orgs.add(await sa.createsOrganization());
  });

  List recs = [];
  await Future.forEach(new List(20), (_) async {
    orgs.shuffle();
    recs.add(await sa.createsReception(orgs.first));
  });

  await Future.forEach(new List(40), (_) async {
    await sa.createsContact();
  });

  await Future.forEach(new List(40), (_) async {
    recs.shuffle();
    await sa.addsContactToReception(await sa.createsContact(), recs.first);
  });

  await Future.forEach(new List(10), (_) async {
    await sa.createsDialplan(mustBeValid: true);
  });

  await Future.forEach(new List(10), (_) async {
    await sa.createsIvrMenu();
  });

  final authserver = await env.requestAuthserverProcess();
  final notificationserver = await env.requestNotificationserverProcess();
  await env.requestFreeswitchProcess();
  final callflow = await env.requestCallFlowProcess();
  final dialplanserver = await env.requestDialplanProcess();
  final calendarserver = await env.requestCalendarserverProcess();
  final contactserver = await env.requestContactserverProcess();
  final messageserver = await env.requestMessageserverProcess();
  final receptionserver = await env.requestReceptionserverProcess();
  final userserver = await env.requestUserserverProcess();
  final configserver = await env.requestConfigServerProcess();
  final configClient = configserver.createClient(env.httpClient);

  configClient.register(key.authentication, authserver.uri);
  configClient.register(key.calendar, calendarserver.uri);
  configClient.register(key.callflow, callflow.uri);
  //configClient.register(key.cdr, cdrserver.uri);
  configClient.register(key.contact, contactserver.uri);
  configClient.register(key.dialplan, dialplanserver.uri);
  configClient.register(key.message, messageserver.uri);
  configClient.register(key.notification, notificationserver.uri);
  configClient.register(key.notificationSocket, notificationserver.notifyUri);
  configClient.register(key.user, userserver.uri);
  configClient.register(key.reception, receptionserver.uri);

  final clientConfig = await configClient.clientConfig();
  final JsonEncoder jsonpp = new JsonEncoder.withIndent('  ');

  print("Client config:");
  print(jsonpp.convert(clientConfig));
  print("Config server is reachable on ${configserver.uri}");
  print("Stack is accessible by using tokens:");
  print('  ' + authserver.tokenDir.tokens.join('\n  '));

  timer.stop();
  print('Stack startup time: ${timer.elapsedMilliseconds}ms');

  ProcessSignal.SIGINT.watch().listen((_) async {
    final teardownTimer = new Stopwatch()..start();
    await env.clear();
    await env.finalize();
    teardownTimer.stop();
    print('Stack shutdown time: ${teardownTimer.elapsedMilliseconds}ms');
    exit(0);
  });
}
