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

/// Various bit's and pieces of tools and utilites.
library openreception.framework.utilities;

import 'package:intl/intl.dart';

/// Helper class for handling language specific weekday names.
class WeekDays {
  final Map<int, String> _map = new Map<int, String>();

  /// Create a new WeekDays object, providing names for each day.
  WeekDays(String monday, String tuesday, String wednesday, String thursday,
      String friday, String saturday, String sunday) {
    _map[1] = monday;
    _map[2] = tuesday;
    _map[3] = wednesday;
    _map[4] = thursday;
    _map[5] = friday;
    _map[6] = saturday;
    _map[7] = sunday;
  }

  /// Localized monday string
  String get monday => _map[1];

  /// Localized tuesday string
  String get tuesday => _map[2];

  /// Localized wednesday string
  String get wednesday => _map[3];

  /// Localized thursday string
  String get thursday => _map[4];

  /// Localized friday string
  String get friday => _map[5];

  /// Localized saturday string
  String get saturday => _map[6];

  /// Localized sunday string
  String get sunday => _map[7];

  /// Return the name of the [weekDayNumber] day. Monday is 1 and Sunday is 7.
  String name(int weekDayNumber) => _map[weekDayNumber];
}

/// Serialization function for transferring time from server to client and visa
/// versa.
/// May return DateTime [never].
int dateTimeToUnixTimestamp(DateTime time) => time.isAtSameMomentAs(never)
    ? never.millisecondsSinceEpoch
    : time.millisecondsSinceEpoch;

/// De-serialization function for transferring time from server to client and
/// visa versa.
/// May return DateTime [never].
DateTime unixTimestampToDateTime(int millisecondsSinceEpoch) =>
    millisecondsSinceEpoch != never.millisecondsSinceEpoch
        ? new DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch)
        : never;

/// Remove the trailing slashes from [host].
String removeTailingSlashes(Uri host) {
  String _trimmedHostname = host.toString();

  while (_trimmedHostname.endsWith('/')) {
    _trimmedHostname =
        _trimmedHostname.substring(0, _trimmedHostname.length - 1);
  }

  return _trimmedHostname;
}

/// Return the [timestamp] in a nice human-readable format.
String humanReadableTimestamp(DateTime timestamp, WeekDays weekDays) {
  final DateTime now = new DateTime.now();
  final StringBuffer sb = new StringBuffer();
  String space = '';

  final String day = new DateFormat.d().format(timestamp);
  final String hourMinute = new DateFormat.Hm().format(timestamp);
  final String month = new DateFormat.M().format(timestamp);
  final String year = new DateFormat.y().format(timestamp);

  if (new DateFormat.yMd().format(timestamp) !=
      new DateFormat.yMd().format(now)) {
    sb.write('${weekDays.name(timestamp.weekday)} $day/$month');
    space = ' ';
  }

  if (timestamp.year != now.year) {
    sb.write('/${year.substring(2)}');
    space = ' ';
  }

  sb.write('$space$hourMinute');

  return sb.toString();
}

/// Obfuscate a password of length 3 or above.
String obfuscatePassword(String string) => string.length > 3
    ? '${string.split('').first}'
        '${string.split('').skip(1).take(string.length-2)
          .map((_) => '*').join('')}'
        '${string.substring(string.length -1)}'
    : string;

/// 'Magic' DateTime indicating that something has neber happended.
final DateTime never = _epoch;

/// Epoch. Used by [never].
final DateTime _epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

/// Return the weeknumber for [timestamp]
///
/// Reference: https://en.wikipedia.org/wiki/ISO_week_date
int weekNumber(DateTime timestamp) {
  final int ordinalDay =
      timestamp.difference(new DateTime(timestamp.year)).inDays + 1;
  final int weekDay = timestamp.weekday;
  int weekNumber = ((ordinalDay - weekDay + 10) / 7).floor();

  if (weekNumber == 0) {
    // Timestamp is in last week of previous year. Recalculate!
    final DateTime ldpy = new DateTime(timestamp.year - 1, 12, 31);
    final int pod = ldpy.difference(new DateTime(ldpy.year)).inDays + 1;
    final int pwd = ldpy.weekday;
    weekNumber = ((pod - pwd + 10) / 7).floor();
  }

  return weekNumber;
}
