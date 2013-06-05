/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library logger;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;

import 'package:logging/logging.dart';

import 'common.dart';
import 'configuration.dart';
import 'protocol.dart' as protocol;

final Log log = new Log._internal();

/**
 * [Log] manages the logging system. Log messages are written to the system using
 * the [debug()], [info()], [error()] and [critical()] methods, each of which
 * represents a log level equivalent to its name.
 *
 * Log messages of levels INFO, ERROR and CRITICAL are sent to Alice according
 * to [configuration.serverLogLevel]. DEBUG log messages are sent to console.
 *
 * Users of [Log] can listen for select log records on the [userLogStream]. See
 * [info()], [error()] and [critical()] for more information.
 */
class Log{
  /**
   * Loglevels that represent the levels on the server side.
   */
  static const Level DEBUG = const Level('Debug', 300);
  static const Level INFO = const Level('Info', 800);
  static const Level ERROR = const Level('Error', 1000);
  static const Level CRITICAL = const Level('Critical', 1200);

  final Logger _logger  = new Logger("System");
  final Logger _ulogger = new Logger("User");

  Stream<LogRecord> get userLogStream => _ulogger.onRecord;

  /**
   * [Log] constructor.
   */
  Log._internal() {
    hierarchicalLoggingEnabled = true; // we need this to keep things sane.

    _logger.parent.level = Level.ALL;
    _ulogger.parent.level = Level.ALL;

    _registerEventListeners();
  }

  /**
   * Log [message] with level [CRITICAL]. If [toUserLog] is true then [message]
   * is also dumped to [userLogStream].
   */
  void critical (String message, {bool toUserLog: false}) {
    if (toUserLog) {
      _ulogger.log(CRITICAL, message);
    } else {
      _logger.log(CRITICAL, message);
    }
  }

  /**
   * Log [message] with level [DEBUG]. DEBUG level messages are only logged to
   * console.
   */
  void debug (String message) => print('DEBUG - ${message}');

  /**
   * Log [message] with level [ERROR]. If [toUserLog] is true then [message]
   * is also dumped to [userLogStream].
   */
  void error(String message, {bool toUserLog: false}) {
    if (toUserLog) {
      _ulogger.log(ERROR, message);
    } else {
      _logger.log(ERROR, message);
    }
  }

  /**
   * Log [message] with level [INFO]. If [toUserLog] is true then [message]
   * is also dumped to [userLogStream].
   */
  void info(String message, {bool toUserLog: false}) {
    if (toUserLog) {
      _ulogger.log(INFO, message);
    } else {
      _logger.log(INFO, message);
    }
  }

  /**
   * Writes [record] to the console and then sends it to Alice.
   */
  void _logSubscriber(LogRecord record) {
    print('${record.loggerName} - ${record.sequenceNumber} - ${record.level.name} - ${record.message}');
    _serverLog(record);
  }

  /**
   * Registers event listeners.
   */
  _registerEventListeners() {
    _logger.onRecord.listen(_logSubscriber);
    _ulogger.onRecord.listen(_logSubscriber);
  }

  /**
   * Sends the log [record] to Alice.
   */
  _serverLog(LogRecord record) {
    Level serverLogLevel = configuration.serverLogLevel;

    if (serverLogLevel <= record.level) {
      String text = '${record.loggerName} - ${record.sequenceNumber} - ${record.message}';

      if (record.level > Level.INFO && record.level <= Level.SEVERE) {
        protocol.logError(text).then((protocol.Response response) {
          if (response.status != protocol.Response.OK) {
            print('CRITICAL server logging error: ${response.data}');
          }
        })
        .catchError((e) {
          print('CRITICAL server logging error: ${e.toString()}');
        });

      } else if (record.level > Level.SEVERE) {
        protocol.logCritical(text).then((protocol.Response response) {
          if (response.status != protocol.Response.OK) {
            print('CRITICAL server logging error: ${response.data}');
          }
        })
        .catchError((e) {
          print('CRITICAL server logging error: ${e.toString()}');
        });

      } else {
        protocol.logInfo(text).then((protocol.Response response) {
          if (response.status != protocol.Response.OK) {
            print('CRITICAL server logging error: ${response.data}');
          }
        })
        .catchError((e) {
          print('CRITICAL server logging error: ${e.toString()}');
        });
      }
    }
  }
}
