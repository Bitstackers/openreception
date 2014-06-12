library utilities.common;

//import 'dart:io';

import 'package:syslog/syslog.dart';

//import 'package:http/http.dart' as http;
import 'dart:async';
//import 'dart:convert';

void access(String message) => logger.access(message);
void log(String message) => logger.debug(message);

BasicLogger logger = new BasicLogger();

Future activateSyslog(String hostname) {
  return _SysLogger.open(hostname).then((BasicLogger value) {
    logger = value;
    return logger;
  });
}


class BasicLogger {
  
  static final int DEBUG    = 255;
  static final int INFO     = 10;
  static final int ERROR    = 5;
  static final int CRITICAL = 0;
  
  int loglevel = DEBUG;
  
  void debugContext(String message, String context) => (this.loglevel >= DEBUG ? 
                                                       print('[DEBUG]  ${new DateTime.now()} - $context - $message') : null);
  void infoContext(String message, String context)  => print('[INFO]   ${new DateTime.now()} - $context - $message');
  void errorContext(String message, String context) => print('[ERROR]  ${new DateTime.now()} - $context - $message');
  void access(String message)                       => print('[ACCESS] ${new DateTime.now()} - $message');
  void debug(String message) => print('[DEBUG] $message');
  void error(String message) => print('[ERROR] $message');
  void critical(String message) => print('[CRITICAL] $message');
}

class _SysLogger extends BasicLogger {
  Syslog _syslog;
  
  _SysLogger(Syslog this._syslog);
  
  static Future open(String hostname) => Syslog.open(hostname).then((Syslog syslog) => new _SysLogger(syslog));
  
  void debug(String message) => _syslog.log(Facility.user, Severity.Debug, message);  
  void error(String message) => _syslog.log(Facility.user, Severity.Error, message);  
  void critical(String message) => _syslog.log(Facility.user, Severity.Critical, message);
}

int dateTimeToUnixTimestamp(DateTime time) {
  return time.millisecondsSinceEpoch~/1000; 
}

String dateTimeToJson(DateTime time) {
  //TODO We should find a format.
  return time.toString(); 
}

DateTime JsonToDateTime(String json) {
  return DateTime.parse(json);
}
