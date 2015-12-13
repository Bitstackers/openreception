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

part of openreception.event;

abstract class EventTemplate {
  static Map _rootElement(Event event) => {
    Key.event     : event.eventName,
    Key.timestamp : Util.dateTimeToUnixTimestamp (event.timestamp)
  };

  static Map call(CallEvent event) =>
      _rootElement(event)..addAll( {Key.call : event.call.toJson()});

  static Map peer(PeerState event) =>
      _rootElement(event)..addAll( {Key.peer : event.peer.toJson()});

  static Map userState(UserState event) =>
      _rootElement(event)..addAll(event.status.asMap);

  static Map channel(ChannelState event) =>
      _rootElement(event)..addAll(
           {Key.channel :
             {Key.ID : event.channelID}});

  static Map connection(ClientConnectionState event) =>
      _rootElement(event)..addAll({Key.state : event.conn});
}