library tokenWatch;

import 'dart:async';

import 'package:logging/logging.dart';
import 'configuration.dart';
import 'token_vault.dart';
import 'package:openreception_framework/common.dart';

const String libraryName = 'AuthServer.tokenWatch';

final Logger log = new Logger ('$libraryName');

void setup() {
  int minutes = 10;
  new Timer.periodic(new Duration(seconds: minutes), _timerTick);
  log.info('Periodic timer started');
}

void seen(String token) {
  Map data = vault.getToken(token);
  data['expiresAt'] = dateTimeToJson(new DateTime.now().add(config.tokenexpiretime));
  vault.updateToken(token, data);
}

void _timerTick(Timer timer) {
  Iterable<String> tokens = vault.listUserTokens().toList();
  for(String token in tokens) {
    Map data = vault.getToken(token);
    DateTime expiresAt = JsonToDateTime(data['expiresAt']);

    int now = new DateTime.now().millisecondsSinceEpoch;
    if(now > expiresAt.millisecondsSinceEpoch) {
      log.info('This token ${token} expired ${expiresAt} - removing it');
      vault.removeToken(token);
    }
  }
}