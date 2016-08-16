library openreception_tests.benchmark;

import 'dart:async';
import 'package:openreception_tests/support.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;

import 'package:test/test.dart';
import 'package:logging/logging.dart';

part 'benchmark/benchmark-call.dart';

const String _namespace = 'test.benchmark';

/**
 * TODO: Add filestore stress-tests.
 *
 */

void allTests() {
  group(_namespace + '.Call', () {
    Logger _log = new Logger(_namespace + '.Call');
    ServiceAgent sa;
    TestEnvironment env;
    Set<Receptionist> receptionists = new Set<Receptionist>();
    Set<Customer> customers = new Set<Customer>();

    /// Transient object
    model.ReceptionDialplan rdp1;
    model.ReceptionDialplan rdp2;
    model.ReceptionDialplan rdp3;
    model.ReceptionDialplan rdp4;

    setUp(() async {
      env = new TestEnvironment();
      sa = await env.createsServiceAgent();

      final org = await sa.createsOrganization();

      rdp1 = await sa.createsDialplan();
      rdp2 = await sa.createsDialplan();
      rdp3 = await sa.createsDialplan();
      rdp4 = await sa.createsDialplan();
      await sa.deploysDialplan(rdp1, await sa.createsReception(org));
      await sa.deploysDialplan(rdp2, await sa.createsReception(org));
      await sa.deploysDialplan(rdp3, await sa.createsReception(org));
      await sa.deploysDialplan(rdp4, await sa.createsReception(org));

      _log.info('Generating receptionists');

      await Future.forEach(new List.generate(5, (i) => i),
          (_) async => receptionists.add(await sa.createsReceptionist()));

      _log.info('Generating customers');
      await Future.forEach(new List.generate(6, (i) => i),
          (_) async => customers.add(await sa.spawnCustomer()));
    });

    tearDown(() async {
      // Logger.root.finest(
      //     'FSLOG:\n ${(await env.requestFreeswitchProcess()).latestLog.readAsStringSync()}');
      await env.clear();
    });

    test(
        'call-rush',
        () =>
            Call.callRush([rdp1, rdp2, rdp3, rdp4], receptionists, customers));
  });
}
