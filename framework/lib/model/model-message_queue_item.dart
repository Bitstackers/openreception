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

part of openreception.framework.model;

class MessageQueueEntry {
  final DateTime createdAt;
  Set<MessageEndpoint> _handledRecipients = new Set();
  int id = noId;
  static const int noId = 0;
  int tries = 0;
  Set<MessageEndpoint> _unhandledRecipients = new Set();

  /**
   * Constructor
   */
  Message message = new Message.empty();

  /**
   * Decoding factory.
   */
  static MessageQueueEntry decode(Map map) =>
      new MessageQueueEntry.fromMap(map);

  Iterable<MessageEndpoint> get handledRecipients => _handledRecipients;

  /**
   * Update the handled recipients set. This operation will automatically
   * remove the handled recipients from the unhandled set.
   */
  set handledRecipients(Iterable<MessageEndpoint> handled) {
    _unhandledRecipients = _unhandledRecipients.difference(handled.toSet());
    _handledRecipients.addAll(handled);
  }

  /**
   * Default empty constructor.
   */
  MessageQueueEntry.empty() : createdAt = new DateTime.now();

  /**
   * Creates a message from the information given in [map].
   */
  MessageQueueEntry.fromMap(Map map)
      : createdAt = Util.unixTimestampToDateTime(map[Key.createdAt]),
        id = map[Key.id],
        message = Message.decode(map[Key.message]),
        _handledRecipients = (map[Key.handledRecipients] as Iterable)
            .map(MessageEndpoint.decode)
            .toSet(),
        _unhandledRecipients = new Set.from(
            map[Key.unhandledRecipients].map(MessageEndpoint.decode)),
        tries = map[Key.tries];

  /**
   * Serialization function
   */
  Map toJson() => {
        Key.id: id,
        Key.tries: tries,
        Key.createdAt: Util.dateTimeToUnixTimestamp(createdAt),
        Key.message: message.toJson(),
        Key.handledRecipients:
            _handledRecipients.map((r) => r.asMap).toList(growable: false),
        Key.unhandledRecipients:
            _unhandledRecipients.map((r) => r.asMap).toList(growable: false)
      };

  Iterable<MessageEndpoint> get unhandledRecipients => _unhandledRecipients;

  /**
   * Set the unhandled recipients set.
   */
  set unhandledRecipients(Iterable<MessageEndpoint> unhandled) {
    _unhandledRecipients = new Set()..addAll(unhandled.toSet());
  }
}
