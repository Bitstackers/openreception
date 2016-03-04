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

class MessageQueueItem {
  static const int noId = 0;
  int id = noId;

  Message message = new Message.empty();

  Set<MessageRecipient> _handledRecipients = new Set();
  Set<MessageRecipient> _unhandledRecipients = new Set();

  Iterable<MessageRecipient> get handledRecipients => _handledRecipients;
  Iterable<MessageRecipient> get unhandledRecipients => _unhandledRecipients;

  /**
   * Update the handled recipients set. This operation will automatically
   * remove the handled recipients from the unhandled set.
   */
  set handledRecipients(Iterable<MessageRecipient> handled) {
    _unhandledRecipients = _unhandledRecipients.difference(handled.toSet());
    _handledRecipients.addAll(handled);
  }

  set unhandledRecipients(Iterable<MessageRecipient> unhandled) {
    _unhandledRecipients = new Set()..addAll(unhandled);
  }

  /**
   * Default empty constructor.
   */
  MessageQueueItem.empty();

  /**
   * Creates a message from the information given in [map].
   */
  MessageQueueItem.fromMap(Map map) {
    id = map[Key.id];
    message = Message.decode(map[Key.message]);

    handledRecipients = map[Key.handledRecipients]
        .map(MessageRecipient.decode)
        .toList(growable: false);
    unhandledRecipients = map[Key.unhandledRecipients]
        .map(MessageRecipient.decode)
        .toList(growable: false);
  }
  /**
   * Serialization function
   */
  Map toJson() => {
        Key.id: id,
        Key.message: message.toJson(),
        Key.handledRecipients:
            handledRecipients.map((r) => r.asMap).toList(growable: false),
        Key.unhandledRecipients:
            unhandledRecipients.map((r) => r.asMap).toList(growable: false)
      };
}
