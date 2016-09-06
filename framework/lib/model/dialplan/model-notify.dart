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

part of orf.model.dialplan;

/// Inject an arbitrary notification with [eventName] into the FreeSWITCH
/// event stream to indicate that a channel has reached a certain point.
///
/// An example may be that the call is announced as available for the
/// agents (receptionist) to pick up.
class Notify implements Action {
  /// The name of the event to send. Remember that ESL clients need to
  /// subscribe to these events to be able to receive them.
  final String eventName;

  /// Create a new [Notify] action with [eventName].
  const Notify(this.eventName);

  /// Parses and creates a new [Notify] action from a [String] [buffer].
  static Notify parse(String buffer) {
    String buf = _consumeKey(buffer.trimLeft(), key.notify).trimLeft();

    _ConsumedIdenBuf consumed = consumeWord(buf);

    String eventName = consumed.iden;
    if (eventName.isEmpty) {
      throw new FormatException('${consumed.iden} is empty', buffer);
    }

    return new Notify(eventName);
  }

  @override
  String toJson() => '${key.notify} $eventName';
}
