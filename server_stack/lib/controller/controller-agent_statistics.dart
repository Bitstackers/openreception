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

library ors.controller.agent_history;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:orf/exceptions.dart';
import 'package:orf/filestore.dart' as filestore;
import 'package:ors/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

class AgentStatistics {
  final filestore.AgentHistory _agentHistory;
  Logger _log = new Logger('ors.controller.agent_history');

  /**
   *
   */
  AgentStatistics(this._agentHistory);

  Future<shelf.Response> today(shelf.Request request) async {
    return okJson(_agentHistory.getRaw(new DateTime.now()));
  }

  Future<shelf.Response> summary(shelf.Request request) async {
    final String dayStr = shelf_route.getPathParameter(request, 'day');
    DateTime day;

    try {
      final List<String> part = dayStr.split('-');

      day = new DateTime(
          int.parse(part[0]), int.parse(part[1]), int.parse(part[2]));
    } catch (e) {
      final String msg = 'Day parsing failed: $dayStr';
      _log.warning(msg, e);
      return clientError(msg);
    }

    try {
      return okJson(await _agentHistory.agentSummay(day));
    } on NotFound {
      return notFound('No stats for the day $dayStr');
    }
  }

  Future<shelf.Response> get(shelf.Request request) async {
    final String dayStr = shelf_route.getPathParameter(request, 'day');
    DateTime day;

    try {
      final List<String> part = dayStr.split('-');

      day = new DateTime(
          int.parse(part[0]), int.parse(part[1]), int.parse(part[2]));
    } catch (e) {
      final String msg = 'Day parsing failed: $dayStr';
      _log.warning(msg, e);
      return clientError(msg);
    }

    try {
      return okGzip(_agentHistory.getRaw(day));
    } on NotFound {
      return notFound('No stats for the day $dayStr');
    }
  }
}
