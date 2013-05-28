/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

/**
 * The logger interface on Bob.
 */
library logger;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'dart:uri';

import 'package:logging/logging.dart';

import 'common.dart';
import 'configuration.dart';
import 'protocol.dart' as protocol;

part 'userlogrecord.dart';

final Log log = new Log._internal();

/**
 * [Log] is a class to manage the logging system.
 */
class Log{
  /**
   * Loglevels that represent the levels on the server side.
   */
  static const DEBUG = const Level('Debug', 300);
  static const INFO = const Level('Info', 800);
  static const ERROR = const Level('Error', 1000);
  static const CRITICAL = const Level('Critical', 1200);

  final Logger _logger = new Logger("Bob");
  final StreamController<UserlogRecord> _userlog = new StreamController<UserlogRecord>();

  Stream<UserlogRecord> get onUserlogMessage => _userlog.stream;

  Log._internal() {
    _logger.onRecord.listen(_logSubscriber);
    _logger.parent.level = Level.ALL;
  }

  /**
   * Log [message] with level [CRITICAL].
   */
  void critical (String message) => _logger.log(CRITICAL, message);

  /**
   * Log [message] with level [DEBUG].
   */
  void debug (String message) => _logger.log(DEBUG, message);

  /**
   * Log [message] with level [ERROR].
   */
  void error(String message) => _logger.log(ERROR, message);

  /**
   * Log [message] with level [INFO].
   */
  void info(String message) => _logger.log(INFO, message);

  /**
   * Writes log to console and send it to Alice.
   */
  void _logSubscriber(LogRecord record) {
    print('${record.sequenceNumber} - ${record.level.name} - ${record.message}');
    _serverLog(record);
  }

  /**
   * Sends log message to Alice.
   */
  _serverLog(LogRecord record) {
    var serverLogLevel = configuration.serverLogLevel;

    if (configuration.serverLogLevel <= record.level) {
      String text = '${record.sequenceNumber} ${record.message}';

      if (record.level > Level.INFO && record.level <= Level.SEVERE) {
        protocol.logError(text)
          .then((protocol.Response response) {
            if (response.status != protocol.Response.OK) {
              print('CRITICAL server logging error: ${response.data}');
            }
          })
          .catchError((e) {
            print('CRITICAL server logging error: ${e.toString()}');
          });

      } else if (record.level > Level.SEVERE) {
        protocol.logCritical(text)
          .then((protocol.Response response) {
          if (response.status != protocol.Response.OK) {
            print('CRITICAL server logging error: ${response.data}');
          }
        })
        .catchError((e) {
          print('CRITICAL server logging error: ${e.toString()}');
        });

      } else {
        protocol.logInfo(text)
          .then((protocol.Response response) {
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

  /**
   * Lets other components listen on the log.
   */
  void user(String message){
    var log = new UserlogRecord(message);
    _userlog.sink.add(log);
  }
}
