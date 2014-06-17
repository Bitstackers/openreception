library tokenWatch;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'cache.dart';
import 'configuration.dart';
import 'token_vault.dart';
import 'package:Utilities/common.dart';

void setup() {
  logger.debug('Watcher started');
  //TODO this should be an isolate
  int minutes = 10;
  new Timer.periodic(new Duration(seconds: minutes), _timerTick);
}

void seen(String token) {
  Map data = vault.getToken(token);
  data['expiresAt'] = dateTimeToJson(new DateTime.now().add(config.tokenexpiretime));
  vault.updateToken(token, data);
}

void _timerTick(Timer timer) {
  Iterable<String> tokens = vault.listTokens();
  for(String token in tokens) {
    Map data = vault.getToken(token);
    DateTime expiresAt = JsonToDateTime(data['expiresAt']);

    int now = new DateTime.now().millisecondsSinceEpoch;
    if(now > expiresAt.millisecondsSinceEpoch) {
      logger.debug('tokenWatch._timerTick() This token ${token} expired ${expiresAt}');
      vault.removeToken(token);
    }
  }
}