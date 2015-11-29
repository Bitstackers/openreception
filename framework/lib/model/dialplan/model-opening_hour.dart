/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model.dialplan;

enum WeekDay { sun, mon, tue, wed, thur, fri, sat, all }

/**
 * Parses a comma-separated buffer into an [Iterable] of [OpeningHour] objects.
 */
Iterable<OpeningHour> parseMultipleHours(String buffer) => buffer
    .split(',')
    .where((string) => string.isNotEmpty)
    .map((ohBuffer) => OpeningHour.parse(ohBuffer));

/**
 * Class representing an opening hour.
 */
class OpeningHour {
  Logger _log = new Logger('$libaryName.OpeningHour');

  WeekDay fromDay;
  int fromHour = 0;
  int fromMinute = 0;

  WeekDay toDay;
  int toHour = 0;
  int toMinute = 0;

  /**
   * Default empty constructor.
   */
  OpeningHour.empty();

  bool isValid() {
    bool result = true;

    if (fromMinute > 59 ||
        toMinute > 59 ||
        fromMinute < 0 ||
        toMinute < 0 ||
        fromHour < 0 ||
        toHour < 0 ||
        fromHour > 23 ||
        toHour > 23) {
      _log.severe('Bad range: ${this}');
      result = false;
    }

    if (fromDay == null) {
      result = false;
    } else if (fromDay != null && toDay != null) {
      if (fromDay.index > toDay.index) {
        _log.severe('FromDay (${fromDay}) is before toDay (${toDay})');
        result = false;
      } else if (fromDay.index == toDay.index) {
        if (fromHour > toHour) {
          _log.severe('FromHour (${fromHour}) is before toDay (${toHour})');
          result = false;
        } else if (fromHour == toHour) {
          if (fromMinute > toMinute) {
            _log.severe(
                'fromMinute (${fromHour}) is before fromMinute (${toHour})');
            result = false;
          }
        }
      }
    }

    return result;
  }

  /**
   * Parsing constructor. Manages formats such as:
   *  mon-fri 8-17
   *  mon 8-17
   *  mon 8:30-17:30
   *
   * Throws [FormatException] when it encounters a parse error. Implicitly runs
   * [validate()], so errors from this function will also result in a
   * [FormatException] for this factory.
   */
  static OpeningHour parse(String buffer) {
    WeekDay weekDayParse(String wDayBuffer) => WeekDay.values.firstWhere(
            (WeekDay wday) => wday.toString() == 'WeekDay.$wDayBuffer',
            orElse: () {
          throw new FormatException('No value for WeekDay.$wDayBuffer');
        });

    OpeningHour openingHour = new OpeningHour.empty();
    bool gotDay = false;
    bool gotHour = false;
    List<String> parts = buffer.split(' ');

    parts.forEach((part) {
      if (!part.isEmpty) {
        if (!gotDay) {
          List<String> days = part.split('-');

          if (days.length > 2) {
            throw new FormatException('Days too long (${days.length}');
          }

          openingHour.fromDay = weekDayParse(days.first);

          if (days.length == 2) {
            openingHour.toDay = weekDayParse(days.last);
          }

          gotDay = true;
        }

        /// Parse hour
        else {
          List<String> intervalParts = part.split('-');

          if (intervalParts.length != 2) {
            throw new FormatException(
                'Interval wrong length: ${intervalParts.length}. '
                'Buffer: "$part"');
          }

          if (intervalParts.first.contains(':')) {
            List<String> segments = intervalParts.first.split(':');

            openingHour.fromHour = int.parse(segments[0]);
            openingHour.fromMinute = int.parse(segments[1]);
          } else {
            openingHour.fromHour = int.parse(intervalParts.first);
          }
          if (intervalParts.last.contains(':')) {
            List<String> segments = intervalParts.last.split(':');

            openingHour.toHour = int.parse(segments[0]);
            openingHour.toMinute = int.parse(segments[1]);
          } else {
            openingHour.toHour = int.parse(intervalParts.last);
          }

          gotHour = true;
        }
      }
    });

    if (!gotDay || !gotHour && openingHour.isValid()) {
      throw new FormatException('Failed to parse buffer "$buffer"');
    }
    if(openingHour.toDay == null) openingHour.toDay = openingHour.fromDay;
    openingHour.isValid();

    return openingHour;
  }

  String get _stringifiedTime => '$fromHour:'
      '${fromMinute < 10 ? '0$fromMinute' : fromMinute}'
      '-$toHour:${toMinute < 10 ? '0$toMinute' : toMinute}';

  String toString() => '${_trimWday(fromDay)}'
      '${toDay != fromDay ? '-${_trimWday(toDay)}' : ''} $_stringifiedTime';

  bool isBefore(OpeningHour other) {
    if (this.toDay.index == other.fromDay.index) {
      if (this.toHour == other.fromHour) {
        return this.fromMinute < other.fromMinute;
      }

      return this.toHour < other.fromHour;
    }

    return this.toDay.index < other.fromDay.index;
  }

  String _trimWday(WeekDay wday) => wday.toString().split('.')[1];

  String toJson() => '${_trimWday(fromDay)}'
      '${toDay != fromDay ? '-${_trimWday(toDay)}' : ''} $_stringifiedTime';

  operator ==(OpeningHour other) => this.toString() == other.toString();
}
