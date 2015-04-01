library server_stack.configuration;

import 'dart:io' as IO;
import 'package:logging/logging.dart';

class Log {
  final Level level = Level.ALL;
  final onRecord = logEntryDispatch;
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

  static final MessageDispatcher messageDispatcher = new MessageDispatcher();
}