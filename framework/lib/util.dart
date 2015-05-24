library openreception.utilities;

import 'package:intl/intl.dart';

/**
 * Helper class for handling language specific weekday names.
 */
class WeekDays {
  final Map<int, String> _map = new Map<int, String>();

  /**
   * Constructor.
   */
  WeekDays(String monday,
           String tuesday,
           String wednesday,
           String thursday,
           String friday,
           String saturday,
           String sunday) {
    _map[1] = monday;
    _map[2] = tuesday;
    _map[3] = wednesday;
    _map[4] = thursday;
    _map[5] = friday;
    _map[6] = saturday;
    _map[7] = sunday;
  }

  String get monday    => _map[1];
  String get tuesday   => _map[2];
  String get wednesday => _map[3];
  String get thursday  => _map[4];
  String get friday    => _map[5];
  String get saturday  => _map[6];
  String get sunday    => _map[7];

  /**
   * Return the name of the [weekDayNumber] day. Monday is 1 and Sunday is 7.
   */
  String name(int weekDayNumber) => _map[weekDayNumber];
}

/**
 *
 */
int dateTimeToUnixTimestamp(DateTime time) =>
  time != null
    ? time.millisecondsSinceEpoch~/1000
    : null;

/**
 *
 */
DateTime unixTimestampToDateTime(int secondsSinceEpoch) =>
  secondsSinceEpoch != null
    ? new DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch*1000)
    : null;


/**
 *
 */
String removeTailingSlashes (Uri host) {
   String _trimmedHostname = host.toString();

   while (_trimmedHostname.endsWith('/')) {
     _trimmedHostname = _trimmedHostname.substring(0, _trimmedHostname.length-1);
   }

   return _trimmedHostname;
}

/**
 * Return the [timestamp] in a nice human-readable format.
 */
String humanReadableTimestamp(DateTime timestamp, WeekDays weekDays) {
  final DateTime     now   = new DateTime.now();
  final StringBuffer sb    = new StringBuffer();
  String             space = '';

  final String day        = new DateFormat.d().format(timestamp);
  final String hourMinute = new DateFormat.Hm().format(timestamp);
  final String month      = new DateFormat.M().format(timestamp);
  final String year       = new DateFormat.y().format(timestamp);

  if(new DateFormat.yMd().format(timestamp) != new DateFormat.yMd().format(now)) {
    sb.write('${weekDays.name(timestamp.weekday)} ${day}/${month}');
    space = ' ';
  }

  if(timestamp.year != now.year) {
    sb.write('/${year.substring(2)}');
    space = ' ';
  }

  sb.write('${space}${hourMinute}');

  return sb.toString();
}
