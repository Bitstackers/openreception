library utilities.common;

import 'dart:io';

import 'package:syslog/syslog.dart';

import 'dart:async';

void log(message) => logger.debug(message.toString());

BasicLogger logger = new BasicLogger();

Future activateSyslog(InternetAddress hostname) {
  return _SysLogger.open(hostname).then((BasicLogger value) {
    logger = value;
    return logger;
  });
}

class BasicLogger {
  void debug(String message) => print('[DEBUG] $message');
  void error(String message) => print('[ERROR] $message');
  void critical(String message) => print('[CRITICAL] $message');
}

class _SysLogger extends BasicLogger {
  Syslog _syslog;
  
  _SysLogger(Syslog this._syslog);
  
  static Future open(InternetAddress hostname) => Syslog.open(hostname).then((Syslog syslog) => new _SysLogger(syslog));
  
  void debug(String message) => _syslog.log(Facility.user, Severity.Debug, message);  
  void error(String message) => _syslog.log(Facility.user, Severity.Error, message);  
  void critical(String message) => _syslog.log(Facility.user, Severity.Critical, message);
}

String dateTimeToJson(DateTime time) {
  //TODO We should find a format.
  return time.toString(); 
}

DateTime JsonToDateTime(String json) {
  return DateTime.parse(json);
}
