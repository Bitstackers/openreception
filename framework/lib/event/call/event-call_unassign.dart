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

part of openreception.framework.event;

/**
 * Event that is meant to be spawned every time a call is unassigned from a
 * user. Currently not in use. Meant for a simplification of the event
 * system.
 */
class CallUnassign extends CallEvent {
  @override
  final String eventName = _Key._callUnassign;
  final int userId;

  CallUnassign(model.Call call, this.userId) : super(call);
  CallUnassign.fromMap(Map map)
      : userId = map[_Key._modifierUid],
        super.fromMap(map);

  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._modifierUid: userId,
        _Key._call: call.toJson()
      };
}
