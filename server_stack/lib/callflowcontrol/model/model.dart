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

library openreception.call_flow_control_server.model;

import 'dart:async';
import 'dart:collection';

import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';
import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/event.dart' as OREvent;
import 'package:openreception_framework/storage.dart' as ORStorage;
import '../controller.dart' as Controller;
import '../router.dart';

part 'model-active_recording.dart';
part 'model-call_list.dart';
part 'model-channel_list.dart';
part 'model-peer.dart';
part 'model-peer_list.dart';
part 'model-user_status_list.dart';

const String libraryName = 'callflowcontrol.model';
