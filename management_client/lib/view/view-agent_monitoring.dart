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

library management_tool.view.agent_monitoring;

import 'dart:async';
import 'dart:html';

import 'package:management_tool/controller.dart' as controller;
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as model;

part 'agent-monitoring/view-agent_info.dart';
part 'agent-monitoring/view-agent_info_list.dart';

String _remoteParty(model.Call call) =>
    call.inbound ? call.callerId : call.destination;
