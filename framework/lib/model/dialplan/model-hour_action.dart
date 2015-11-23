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

/**
 * Class wrapping an ordered list of actions that is guarded by [hours].
 */
class HourAction {
  List<OpeningHour> hours = [];
  List<Action> actions = [];

  String toString () => '${hours.join(', ')} - ${actions.join(',')}';

  static HourAction decode (Map map) =>
      new HourAction()
        ..hours = parseMultipleHours(map['hours'])
        ..actions = map['actions'].map(Action.parse).toList();

  Map toJson() => {
    'hours' : hours.map((hour) => hour.toJson()).join(', '),
    'actions' : actions
  };
}
