/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

final Call nullCall = new Call._null();

/**
 * A call.
 */
class Call implements Comparable {
  int      _assignedAgent;
  int      _id;
  DateTime _start;

  int      get assignedAgent => _assignedAgent;
  int      get id            => _id;
  DateTime get start         => _start;

  /**
   * Call constructor.
   */
  Call.fromJson(Map json) {
    if(json.containsKey('assigned_to')) {
      _assignedAgent = int.parse(json['assigned_to']);
    }

    _id = int.parse(json['id']);
    _start = DateTime.parse(json['start']);

    log.debug('Call.fromJson ${json}');
  }

  /**
   * Call constructor.
   */
  Call._null() {
    _assignedAgent = null;
    _id = null;
    _start = new DateTime.now();
  }

  /**
   * Enables a [Call] to sort itself compared to other calls.
   */
  int compareTo(Call other) => _start.compareTo(other._start);

  /**
   * [Call] as String, for debug/log purposes.
   */
  String toString() => 'Call ${_id} - ${_start}';
}
