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
 * Serialization function for transferring time from server to client and visa
 * versa.
 * May return null to indicate 'never';
 */
int dateTimeToUnixTimestamp(DateTime time) =>
  time != null
    ? time.millisecondsSinceEpoch~/1000
    : null;

/**
 * De-serialization function for transferring time from server to client and
 * visa versa.
 * May return null to indicate 'never';
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
