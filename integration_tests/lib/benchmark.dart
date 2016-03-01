library openreception_tests.benchmark;

import 'dart:async';
import 'package:openreception_tests/support.dart';
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/storage.dart' as storage;

import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';

part 'benchmark/benchmark-call.dart';

const String _namespace = 'test.benchmark';

void runBenchmarkTests() {
  group(_namespace + '.call', () {
    Set<Receptionist> receptionists;
    Set<Customer> customers;

    setUp(() {
      receptionists = new Set();
      customers = new Set();

      while (ReceptionistPool.instance.available.length > 0) {
        receptionists.add(ReceptionistPool.instance.aquire());
      }

      while (CustomerPool.instance.available.length > 0) {
        customers.add(CustomerPool.instance.aquire());
      }

      return Future
          .wait(receptionists
              .map((Receptionist receptionist) => receptionist.initialize()))
          .then((_) => Future.wait(
              customers.map((Customer customer) => customer.initialize())));
    });

    tearDown(() {
      receptionists.forEach(((Receptionist receptionist) =>
          ReceptionistPool.instance.release(receptionist)));

      customers.forEach(
          ((Customer customer) => CustomerPool.instance.release(customer)));

      return Future
          .wait(receptionists
              .map((Receptionist receptionist) => receptionist.teardown()))
          .then((_) => Future
              .wait(customers.map((Customer customer) => customer.teardown())));
    });

    test('call-rush', () => Call.callRush(receptionists, customers));
  });
}
