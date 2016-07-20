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
 * Event that is meant to be spawned every time a call is assigned to a
 * user. Currently not in use. Meant for a simplification of the event
 * system.
 */
class CallAssign extends CallEvent {
  @override
  final String eventName = Key.callAssign;
  final int uid;

  /**
   * Default constructor. Subtypes the general [CallEvent] class. Takes the
   * [model.Call] being assigned and the [uid] of the user it being assigned
   * to as arguments.
   */
  CallAssign(model.Call call, this.uid) : super(call);

  /**
   * Deserializing constructor.
   */
  CallAssign.fromMap(Map map)
      : uid = map[Key.modifierUid],
        super.fromMap(map);

  /**
   * Serialization function.
   */
  @override
  Map toJson() => super.toJson()..addAll({Key.modifierUid: uid});
}
