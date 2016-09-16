/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library ors.authentication.token_watcher;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:ors/configuration.dart';
import 'token_vault.dart';

const String libraryName = 'AuthServer.tokenWatch';

final Logger log = new Logger('$libraryName');

void setup() {
  final Duration tickDuration = new Duration(seconds: 10);
  new Timer.periodic(tickDuration, _timerTick);
  log.info('Periodic timer started');
}

void seen(String token) {
  Map data = vault.getToken(token);
  data['expiresAt'] =
      dateTimeToJson(new DateTime.now().add(config.authServer.tokenLifetime));
  vault.updateToken(token, data);
}

void _timerTick(Timer timer) {
  Iterable<String> tokens = vault.listUserTokens().toList();
  for (String token in tokens) {
    Map data = vault.getToken(token);
    DateTime expiresAt = jsonToDateTime(data['expiresAt']);

    int now = new DateTime.now().millisecondsSinceEpoch;
    if (now > expiresAt.millisecondsSinceEpoch) {
      log.info('This token $token expired $expiresAt - removing it');
      vault.removeToken(token);
    }
  }
}

DateTime jsonToDateTime(String timeString) => DateTime.parse(timeString);
String dateTimeToJson(DateTime time) => time.toString();
