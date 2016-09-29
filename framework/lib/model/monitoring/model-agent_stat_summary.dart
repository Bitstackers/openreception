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

part of orf.model.monitoring;

/// Model class for providing a complete summary of the performance of an
/// agent.
class AgentStatSummary {
  final int uid;
  final int inboundCount;
  final int outBoundCount;
  final Duration inboundDuration;
  final Duration outboundDuration;
  final int messagesSent;
  final int callsAnsweredWithin20s;
  final Duration pauseDuration;

  AgentStatSummary(
      this.uid,
      this.inboundCount,
      this.outBoundCount,
      this.inboundDuration,
      this.outboundDuration,
      this.callsAnsweredWithin20s,
      this.messagesSent,
      this.pauseDuration);

  AgentStatSummary.fromJson(Map map)
      : this.uid = map[_Key.uid],
        this.inboundCount = map[_Key.inbound],
        this.outBoundCount = map[_Key.outbound],
        this.inboundDuration =
            new Duration(milliseconds: map[_Key.inboundHandleTime]),
        this.outboundDuration =
            new Duration(milliseconds: map[_Key.outboundHandleTime]),
        this.callsAnsweredWithin20s = map[_Key.below20s],
        this.messagesSent = map[_Key.messageCount],
        this.pauseDuration =
            new Duration(milliseconds: map[_Key.pauseDuration]);

  Map toJson() => new Map.unmodifiable({
        _Key.uid: uid,
        _Key.inbound: inboundCount,
        _Key.outbound: outBoundCount,
        _Key.inboundHandleTime: inboundDuration.inMilliseconds,
        _Key.outboundHandleTime: outboundDuration.inMilliseconds,
        _Key.below20s: callsAnsweredWithin20s,
        _Key.messageCount: messagesSent,
        _Key.pauseDuration: pauseDuration.inMilliseconds
      });
}
