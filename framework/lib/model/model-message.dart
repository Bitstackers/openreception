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

/**
 * Valid states for a message.
 */
enum MessageState { unknown, saved, sent }

/**
 *
 */
class Message {
  static const int noId = 0;

  Set<MessageEndpoint> recipients = new Set();

  int id = noId;
  MessageContext context = new MessageContext.empty();
  MessageFlag flag = new MessageFlag.empty();
  MessageState state = MessageState.unknown;

  CallerInfo callerInfo;
  DateTime createdAt;
  String body = '';
  String callId = '';

  /// The user of the sender.
  User sender;

  bool get closed => sent || flag.manuallyClosed;
  bool get manuallyClosed => flag.manuallyClosed;
  bool get saved => state == MessageState.saved;
  bool get sent => state == MessageState.sent;

  set manuallyClosed(bool closed) {
    flag.manuallyClosed = closed;
  }

  Message.empty();

  Iterable<MessageEndpoint> get emailTo => recipients
      .where((MessageEndpoint ep) => ep.type == MessageEndpointType.emailTo);

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
        (map[key.recipients] as Iterable).map(MessageEndpoint.decode);

    id = (map.containsKey(key.id) ? map[key.id] : noId);
    recipients.addAll(iterRcp);
    context = new MessageContext.fromMap(map[key.context]);
    flag = new MessageFlag(map['flags'] as List<String>);
    callerInfo = new CallerInfo.fromMap(map[key.caller]);
    body = map[key.body];
    callId = map[key.callId];
    sender = User.decode(map[key.takenByAgent]);
    createdAt = util.unixTimestampToDateTime(map[key.createdAt]);

    if (map[key.state] == null) {
      state = MessageState.unknown;
    } else if (map[key.state] == MessageState.values.length) {
      state = MessageState.unknown;
    } else {
      state = MessageState.values[map[key.state]];
    }
  }

  Map get asMap => {
        key.id: id,
        key.body: body,
        key.context: context.toJson(),
        key.takenByAgent: sender.toJson(),
        key.caller: callerInfo.toJson(),
        key.callId: callId,
        key.flags: flag.toJson(),
        key.createdAt: util.dateTimeToUnixTimestamp(createdAt),
        key.recipients: recipients
            .map((MessageEndpoint ep) => ep.toJson())
            .toList(growable: false),
        key.state: state.index
      };
}
