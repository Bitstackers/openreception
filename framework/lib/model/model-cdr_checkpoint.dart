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

part of openreception.model;

/**
 * A CDR checkpoint is a timespan which is used to delimit which CDR entries
 * should be included in a queried set.
 */
class CDRCheckpoint {
  int id;
  DateTime start;
  DateTime end;
  String name;

  /**
   * Default empty constructor.
   */
  CDRCheckpoint.empty();

  /**
   * Deserializing constructor.
   */
  CDRCheckpoint.fromMap(Map map) {
    id = map[Key.id];
    start = Util.unixTimestampToDateTime(map[Key.start]);
    end = Util.unixTimestampToDateTime(map[Key.end]);
    name = map[Key.name];
  }

  /**
   * JSON representation of the model class.
   */
  Map toJson() => {
    Key.id: id,
    Key.start: Util.dateTimeToUnixTimestamp(start),
    Key.end: Util.dateTimeToUnixTimestamp(end),
    Key.name: name
  };
}

/**
 * Comparator function.
 */
int compareCheckpoint(CDRCheckpoint c1, CDRCheckpoint c2) =>
    c1.end.compareTo(c2.end);
