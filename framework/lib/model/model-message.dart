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

abstract class Role {
  static const String TO = 'to';
  static const String CC = 'cc';
  static const String BCC = 'bcc';

  static final List<String> RECIPIENT_ROLES = [TO, CC, BCC];
}

class Message {
  static const String className = '${libraryName}.Message';
  static const int noID = 0;

  static final Logger log = new Logger(className);

  Set<MessageRecipient> recipients = new Set();

  int ID = noID;
  MessageContext context = new MessageContext.empty();
  MessageFlag flag = new MessageFlag.empty();
  CallerInfo callerInfo;
  DateTime createdAt;
  String body = '';

  /// The user ID of the sender.
  int senderId;
  bool enqueued = false;
  bool sent = false;

  bool get closed => enqueued || sent || flag.manuallyClosed;

  bool get manuallyClosed => flag.manuallyClosed;
  set manuallyClosed(bool closed) {
    flag.manuallyClosed = closed;
  }

  Message.empty();

  Iterable<MessageRecipient> get to =>
    recipients.where((MessageRecipient r) => r.role == Role.TO);

  Iterable<MessageRecipient> get cc =>
    recipients.where((MessageRecipient r) => r.role == Role.CC);

  Iterable<MessageRecipient> get bcc =>
    recipients.where((MessageRecipient r) => r.role == Role.BCC);

  bool get hasRecpients => recipients.isNotEmpty;

  Map toJson() => this.asMap;

  /**
   * TODO: Document.
   */
  Message.fromMap(Map map) {
    Iterable iterRcp =
        (map['recipients'] as Iterable).map(MessageRecipient.decode);

    ID = (map.containsKey(Key.ID) ? map[Key.ID] : noID);
    recipients.addAll(iterRcp);
    context = new MessageContext.fromMap(map['context']);
    flag = new MessageFlag(map['flags']);
    callerInfo = new CallerInfo.fromMap(map['caller']);
    body = map['message'];
    sent = map['sent'];
    enqueued = map['enqueued'];
    senderId = map['taken_by_agent'];
    createdAt = Util.unixTimestampToDateTime(map['created_at']);
  }

  Map get asMap => {
    'id': ID,
    'message': body,
    'context': context.asMap,
    'taken_by_agent': senderId,
    'caller': callerInfo.asMap,
    'flags': flag.toJson(),
    'sent': sent,
    'enqueued': enqueued,
    'created_at': Util.dateTimeToUnixTimestamp(createdAt),
    'recipients':
        recipients.map((MessageRecipient r) => r.asMap).toList(growable: false)
  };
}
