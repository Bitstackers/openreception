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
 * Event that is spawned when the channel of a call destroyed. Must only
 * occur once for every call.
 */
class CallHangup extends CallEvent {
  final String eventName = Key.callHangup;
  final String hangupCause;

  /**
   * Default constructor. Subtypes the general [CallEvent] class. Takes the
   * [model.Call] being hung up as well as an optional [hangupCause].
   * The [hangupCause] should be copied from the PBX hangup reason text.
   */
  CallHangup(model.Call call, {this.hangupCause: ''}) : super(call);

  /**
   * Deserializing constructor.
   */
  CallHangup.fromMap(Map map)
      : hangupCause = map[Key.hangupCause],
        super.fromMap(map);

  /**
   * Serialization function.
   */
  @override
  Map toJson() => super.toJson()..addAll({Key.hangupCause: this.hangupCause});
}
