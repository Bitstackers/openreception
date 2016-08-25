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

part of openreception.server.model;

//TODO: test api command: sofia_presence_data list|status|rpid|user_agent [profile/]<user>@domain
class Peer extends esl.Peer {
  final ChannelList _channelList;

  Peer(this._channelList);

  @override
  UnmodifiableMapView<String, dynamic> toJson() => new UnmodifiableMapView({
        'id': this.id,
        'registered': this.registered,
        'activeChannels': _channelList.activeChannelCount(this.id)
      });
}
