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
  String      _id;
  DateTime _start;

  int      get assignedAgent => _assignedAgent;
  String   get id            => _id;
  DateTime get start         => _start;

  /**
   * [Call] constructor. Expects a map in the following format:
   *
   *  {
   *    'assigned_to' : String,
   *    'id'          : String,
   *    'start'       : DateTime String
   *  }
   *
   * 'assigned_to' is the String agent ID. 'id' is the ID of the call.'start'
   * is a timestamp of when the call was started. It MUST be in a format that
   * can be parsed by the [DateTime.parse] method.
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  Call.fromJson(Map json) {
    log.debug('Call.fromJson ${json}');
    if(json.containsKey('assigned_to') && json['assigned_to'] != null) {
      _assignedAgent = int.parse(json['assigned_to']);
    }

    _id = json['id'];
    //_start = DateTime.parse(json['arrival_time']);
    _start = new DateTime.fromMillisecondsSinceEpoch(int.parse(json['arrival_time'])*1000);
  }

  /**
   * [Call] null constructor.
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
