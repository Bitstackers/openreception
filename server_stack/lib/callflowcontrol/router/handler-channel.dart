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

part of openreception.call_flow_control_server.router;

abstract class Channel {

  static shelf.Response list(shelf.Request request) {
    try {
      List<Map> retval = new List<Map>();
      Model.ChannelList.instance.forEach((channel) {
        retval.add(channel.toMap());
      });

      return new shelf.Response.ok(JSON.encode(retval));
    } catch (error, stacktrace) {
      log.severe(error, stacktrace);
      return new shelf.Response.internalServerError
          (body : 'Failed to retrieve channel list');
    }
  }
}
