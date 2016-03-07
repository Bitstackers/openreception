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

class MessageQueueEntry {
  static const int noId = 0;
  int id = noId;
  int tries = 0;

  Message message = new Message.empty();

  Set<MessageEndpoint> _handledRecipients = new Set();
  Set<MessageEndpoint> _unhandledRecipients = new Set();

  Iterable<MessageEndpoint> get handledRecipients => _handledRecipients;
  Iterable<MessageEndpoint> get unhandledRecipients => _unhandledRecipients;

  /**
   * Update the handled recipients set. This operation will automatically
   * remove the handled recipients from the unhandled set.
   */
  set handledRecipients(Iterable<MessageEndpoint> handled) {
    _unhandledRecipients = _unhandledRecipients.difference(handled.toSet());
    _handledRecipients.addAll(handled);
  }

  set unhandledRecipients(Iterable<MessageEndpoint> unhandled) {
    _unhandledRecipients = new Set()..addAll(unhandled);
  }

  /**
   * Default empty constructor.
   */
  MessageQueueEntry.empty();

  /**
   * Creates a message from the information given in [map].
   */
  MessageQueueEntry.fromMap(Map map)
      : id = map[Key.id],
        message = Message.decode(map[Key.message]),
        _handledRecipients = map[Key.handledRecipients]
            .map(MessageEndpoint.decode)
            .toList(growable: false),
        _unhandledRecipients = map[Key.unhandledRecipients]
            .map(MessageEndpoint.decode)
            .toList(growable: false),
        tries = map[Key.tries];

  /**
   * Serialization function
   */
  Map toJson() => {
        Key.id: id,
        Key.tries: tries,
        Key.message: message.toJson(),
        Key.handledRecipients:
            _handledRecipients.map((r) => r.asMap).toList(growable: false),
        Key.unhandledRecipients:
            _unhandledRecipients.map((r) => r.asMap).toList(growable: false)
      };
}
