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

library utilities.common;

void access(String message) => logger.access(message);
void log(String message) => logger.debug(message);

BasicLogger logger = new BasicLogger();

class BasicLogger {

  static final int DEBUG    = 255;
  static final int INFO     = 10;
  static final int ERROR    = 5;
  static final int CRITICAL = 0;

  int loglevel = DEBUG;

  void debugContext(message, String context) => (this.loglevel >= DEBUG ?
                                                       print('[DEBUG]  ${new DateTime.now()} - $context - $message') : null);
  void infoContext(message, String context)  => print('[INFO]   ${new DateTime.now()} - $context - $message');
  void errorContext(message, String context) => print('[ERROR]  ${new DateTime.now()} - $context - $message');
  void access(message)                       => print('[ACCESS] ${new DateTime.now()} - $message');
  void debug(message) => print('[DEBUG] $message');
  void error(message) => print('[ERROR] $message');
  void critical(message) => print('[CRITICAL] $message');
}
/**
 * Time serialization function.
 */
int dateTimeToUnixTimestamp(DateTime time) {
  return time.toUtc().millisecondsSinceEpoch~/1000;
}

/**
 * Time serialization function.
 */
DateTime unixTimestampToDateTime(int secondsSinceEpoch) {
  return new DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch*1000, isUtc: true);
}

/**
 * Time serialization function.
 *
 * TODO: Figure out a format, or migrate to the unix timestamp version above.
 */
String dateTimeToJson(DateTime time) => time.toString();

/**
 * Time de-serialization function.
 *
 * TODO: Figure out a format, or migrate to the unix timestamp version above.
 */

DateTime JsonToDateTime(String timeString) => DateTime.parse(timeString);
