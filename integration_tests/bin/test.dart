import 'dart:async' as async;

import 'package:phonio/phonio.dart';
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/service-io.dart' as Transport;
import '../lib/or_test_fw.dart';
import '../lib/managementserver.dart' as mgt;

import 'package:logging/logging.dart';

import '../lib/config.dart';

async.Future main() {
  List<Receptionist> receptionists = [];

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

      receptionists.add(new Receptionist(phone, token, user));

      return ConfigPool.hasAvailableLocalSipAccount();
    });

  void printReceptionists() =>
    receptionists.forEach((Receptionist receptionist) {
      print (receptionist);

    });

  /// Construct a map of users, identified by their token.
  return
      buildUserMap()
      .then((_) => setupReceptionists())
      .then((_) => printReceptionists())
      .whenComplete(() {
    tokenMap.forEach ((token, user) {
      print ('$token : ${user.ID}, ${user.peer}');
    });
  });

}

//
//async.Future runTests () {
//  return ForwardCall.forward_call_1_a_II();
//
//  List tests = [IncomingCall.incomingCall_1_a_II,
//                ForwardCall.forward_call_1_a_II];
//
//  return async.Future.forEach(tests, (_) => null);
//}

void testServerStack() {
  mgt.runAllTests();
}
