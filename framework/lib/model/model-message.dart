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

class Message {
  static const int noId = 0;

  Set<MessageEndpoint> recipients = new Set();

  int id = noId;
  MessageContext context = new MessageContext.empty();
  MessageFlag flag = new MessageFlag.empty();
  CallerInfo callerInfo;
  DateTime createdAt;
  String body = '';
  String callId = '';

  /// The user of the sender.
  User sender;

  bool get manuallyClosed => flag.manuallyClosed;
  set manuallyClosed(bool closed) {
    flag.manuallyClosed = closed;
  }

  Message.empty();

  Iterable<MessageEndpoint> get emailTo =>
      recipients.where((MessageEndpoint ep) =>
          ep.type == MessageEndpointType.emailTo ||
          ep.type == MessageEndpointType.email);

  Iterable<MessageEndpoint> get emailCc => recipients
      .where((MessageEndpoint ep) => ep.type == MessageEndpointType.emailCc);

  Iterable<MessageEndpoint> get emailBcc => recipients
      .where((MessageEndpoint ep) => ep.type == MessageEndpointType.emailBcc);

  Iterable<MessageEndpoint> get sms => recipients
      .where((MessageEndpoint ep) => ep.type == MessageEndpointType.sms);

  bool get hasRecpients => recipients.isNotEmpty;

  Map toJson() => this.asMap;

  static Message decode(Map map) => new Message.fromMap(map);

  /**
   *
   */
  Message.fromMap(Map map) {
    Iterable<MessageEndpoint> iterRcp =
        (map[Key.recipients] as Iterable).map(MessageEndpoint.decode);

    id = (map.containsKey(Key.id) ? map[Key.id] : noId);
    recipients.addAll(iterRcp);
    context = new MessageContext.fromMap(map[Key.context]);
    flag = new MessageFlag(map['flags'] as List<String>);
    callerInfo = new CallerInfo.fromMap(map[Key.caller]);
    body = map[Key.body];
    callId = map[Key.callId];
    sender = User.decode(map[Key.takenByAgent]);
    createdAt = Util.unixTimestampToDateTime(map[Key.createdAt]);
  }

  Map get asMap => {
        Key.id: id,
        Key.body: body,
        Key.context: context.toJson(),
        Key.takenByAgent: sender.toJson(),
        Key.caller: callerInfo.toJson(),
        Key.callId: callId,
        Key.flags: flag.toJson(),
        Key.createdAt: Util.dateTimeToUnixTimestamp(createdAt),
        Key.recipients: recipients
            .map((MessageEndpoint ep) => ep.toJson())
            .toList(growable: false)
      };
}
