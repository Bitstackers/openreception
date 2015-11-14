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

part of openreception.call_flow_control_server.controller;

class AgentStatistics {

  final Model.AgentHistory _agentHistory;

  AgentStatistics(this._agentHistory);

  shelf.Response list (_) =>
      _okJson(_agentHistory.toList(growable: false));

  shelf.Response get (shelf.Request request) {
    final int uid = int.parse(shelf_route.getPathParameter(request, 'uid'));

    try {
      return  _okJson(_agentHistory.sumUp(uid));
    }
    on ORStorage.NotFound {
      return _notFound('No stats for agent with uid $uid');
    }
  }

}