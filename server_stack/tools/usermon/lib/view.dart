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

library usermon.view;

import 'dart:html';
import 'package:logging/logging.dart';
import 'package:orf/event.dart' as event;
import 'package:orf/model.dart' as model;
import 'package:orf/service.dart' as service;

part 'view/agent_info.dart';
part 'view/agent_info_list.dart';
part 'view/call.dart';
part 'view/call_stats.dart';
part 'view/call_list.dart';

String _remoteParty(model.Call call) =>
    call.inbound ? call.callerId : call.destination;
