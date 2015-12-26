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
 * Abstract super-class for [Action]s available for the dialplan.
 */
abstract class Action {

  /**
   * Parsing constructor. Will return a specific [Action] (such as [Transfer]
   * or [Voicemail]. Will throw or propagate [FormatException] on parse errors.
   * Note: Every specialization of an [Action] _must_ override the [parse]
   * method. Otherwise a stack overflow will occur.
   */
  static Action parse(dynamic buffer) {
    final consumed = consumeWord(buffer);

    switch (consumed.iden) {
      case Key.transfer:
        return Transfer.parse(buffer);

      case Key.voicemail:
        return Voicemail.parse(buffer);

      case Key.enqueue:
        return Enqueue.parse(buffer);

      case Key.notify:
        return Notify.parse(buffer);

      case Key.playback:
        return Playback.parse(buffer);

      case Key.ringtone:
        return Ringtone.parse(buffer);

      case Key.ivr:
        return Ivr.parse(buffer);

      case Key.reception:
        return ReceptionTransfer.parse(buffer);

      default:
        throw new FormatException('Unknown keyword', consumed.iden);
    }

    throw new FormatException('Invalid buffer', buffer);
  }

  /**
   * Default constructor (interface).
   */
  const Action();

  /**
   * Every action _must_ have a serialization function.
   */
  dynamic toJson();
}
