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

library openreception.configuration;

import 'dart:io' as IO;
import 'package:logging/logging.dart';

class Log {
  final Level level = Level.ALL;
  final onRecord = logEntryDispatch;
}

class ConfigServerDefault {
  int HttpPort = 4080;
}
abstract class StandardConfig {
  final Log log = Configuration.logDefaults;
  final String serverToken = 'ielooch6eig8ie5U';
}

class CallFlowControl extends StandardConfig {
  final String dialoutPrefix = '';

  /// The user contexts to load peers from. All other contexts will be ignored.
  final Iterable<String> peerContexts =
    ['default', 'receptions', 'test-receptions'];
}

class ConfigServer extends StandardConfig {
  final ConfigServerDefault defaults = new ConfigServerDefault ();
}

class AuthServer extends StandardConfig {
  final Duration tokenexpiretime = new Duration(hours : 12);
}

class ContactServer extends StandardConfig {}
class CDRServer extends StandardConfig {}
class MessageDispatcher extends StandardConfig {}
class UserServer extends StandardConfig {}
class ManagementServer extends StandardConfig {}
class MessageServer extends StandardConfig {}
class NotificationServer extends StandardConfig {}
class ReceptionServer extends StandardConfig {}

void logEntryDispatch(LogRecord record) {
  if (record.level.value > Level.INFO.value) {
    IO.stderr.writeln(record);
  } else {
    IO.stdout.writeln(record);
  }
}

abstract class Configuration {
  static final logDefaults = new Log();

  static final AuthServer authServer = new AuthServer();
  static final CallFlowControl callFlowControl = new CallFlowControl();
  static final ConfigServer configserver = new ConfigServer();
  static final ContactServer contactServer = new ContactServer();
  static final MessageDispatcher messageDispatcher = new MessageDispatcher();
  static final CDRServer cdrServer= new CDRServer();
  static final ManagementServer managementServer= new ManagementServer();
  static final MessageServer messageServer= new MessageServer();
  static final NotificationServer notificationServer= new NotificationServer();
  static final ReceptionServer receptionServer= new ReceptionServer();
  static final UserServer userServer= new UserServer();

}