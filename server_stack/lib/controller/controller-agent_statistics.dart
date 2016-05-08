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

library openreception.server.controller.agent_history;

import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception.server/model.dart' as model;
import 'package:openreception.server/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

class AgentStatistics {
  final model.AgentHistory _agentHistory;

  AgentStatistics(this._agentHistory);

  shelf.Response list(_) => okJson(_agentHistory);

  shelf.Response get(shelf.Request request) {
    final int uid = int.parse(shelf_route.getPathParameter(request, 'uid'));

    try {
      return okJson(_agentHistory.sumUp(uid));
    } on storage.NotFound {
      return notFound('No stats for agent with uid $uid');
    }
  }
}
