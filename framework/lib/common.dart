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
