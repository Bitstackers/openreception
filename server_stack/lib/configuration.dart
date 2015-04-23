library server_stack.configuration;

import 'dart:io' as IO;
import 'package:logging/logging.dart';

class Log {
  final Level level = Level.ALL;
  final onRecord = logEntryDispatch;
}

class ConfigServerDefault {
  int HttpPort = 4080;
}

class CallFlowControl {
  final Log log = Configuration.logDefaults;
  final String dialoutPrefix = '';
}

class ConfigServer {
  final ConfigServerDefault defaults = new ConfigServerDefault ();

  final Log log = Configuration.logDefaults;
}

class MessageDispatcher {
  final Log log = Configuration.logDefaults;
}

void logEntryDispatch(LogRecord record) {
  if (record.level.value > Level.WARNING.value) {
    IO.stderr.writeln(record);
  } else {
    IO.stdout.writeln(record);
  }
}

abstract class Configuration {
  static final logDefaults = new Log();

  static final CallFlowControl callFlowControl = new CallFlowControl();
  static final ConfigServer configserver = new ConfigServer();
  static final MessageDispatcher messageDispatcher = new MessageDispatcher();
}