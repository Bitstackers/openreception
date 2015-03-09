import 'dart:async' as async;

import 'package:phonio/phonio.dart';
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/service-io.dart' as Transport;
import '../lib/or_test_fw.dart';
import '../lib/managementserver.dart' as mgt;

import 'package:logging/logging.dart';

import '../lib/config.dart';

final enabledTests = [Hangup.eventPresence
                          //ForwardCall.forward_call_1_a_II
                          ];


async.Future main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  List<Receptionist> receptionists = [];
  List<Customer> customers = [];

  /// Maps token to a User object.
  Map<String, Model.User> tokenMap = {};

  /// Maps a peerID to a token.
  Map<String, String> peerMap = {};

  Service.Authentication authService = new Service.Authentication
      (Config.authenticationServerUri, Config.serverToken, new Transport.Client());

  async.Future buildUserMap() =>
      async.Future.forEach(Config.authTokens, ((String token) =>
          authService.userOf(token).then((Model.User user) {
              tokenMap[token] = user;
              peerMap[user.peer] = token;
      })));


  async.Future setupReceptionists() =>
    async.Future.doWhile(() {

      SIPAccount account = ConfigPool.requestLocalSipAccount();
      String token = peerMap[account.username];
      SIPPhone phone = new PJSUAProcess(Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());
      Model.User user = tokenMap[token];

      phone.addAccount(account);

      Receptionist receptionist = new Receptionist(phone, token, user);

      receptionists.add(receptionist);
      return ConfigPool.hasAvailableLocalSipAccount();

    })
    .whenComplete(() =>
        ReceptionistPool.instance = new ReceptionistPool(receptionists));

  async.Future initializeReceptionists() =>
      async.Future.forEach (receptionists,
          (Receptionist receptionist) => receptionist.initialize());

  async.Future setupCustomers() =>
    async.Future.doWhile(() {

      SIPAccount account = ConfigPool.requestExternalSIPAccount();
      SIPPhone phone = new PJSUAProcess(Config.simpleClientBinaryPath, ConfigPool.requestPjsuaPort());

      phone.addAccount(account);

      customers.add(new Customer(phone));


      return ConfigPool.hasAvailableExternalSipAccount();
    })
    .whenComplete(() =>
        CustomerPool.instance = new CustomerPool(customers));

  async.Future initializeCustomers() =>
      async.Future.forEach (customers,
          (Customer customer) => customer.initialize());

  void tearDownReceptionists () => receptionists.forEach
      ((Receptionist receptionist) => receptionist.teardown());

  void tearDownCustomers () => customers.forEach
      ((Customer customer) => customer.teardown());


  void printCustomers() => customers.forEach(print);

  void printReceptionists() => receptionists.forEach(print);

  /// Construct a map of users, identified by their token.
  return
      buildUserMap()
      .then((_) => setupReceptionists())
      .then((_) => initializeReceptionists())
      .then((_) => printReceptionists())
      .then((_) => setupCustomers())
      .then((_) => initializeCustomers())
      .then((_) => printCustomers())
      .then((_) => Hangup.eventPresence())
      .then((_) => tearDownReceptionists())
      .then((_) => tearDownCustomers())
      .then((_) => print ("All tests have run."))
      .whenComplete(() {
    tokenMap.forEach ((token, user) {
      print ('$token : ${user.ID}, ${user.peer}');
    });
  });
}

void testServerStack() {
  mgt.runAllTests();
}
