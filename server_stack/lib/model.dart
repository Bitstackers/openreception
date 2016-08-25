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

library openreception.server.model;

import 'dart:async';
import 'dart:collection';

import 'package:esl/esl.dart' as esl;
import 'package:esl/constants.dart' as esl_const;
import 'package:logging/logging.dart';
import 'package:openreception.framework/bus.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/exceptions.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/pbx-keys.dart';
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/controller/controller-pbx.dart'
    as controller;

part 'model/model-active_recording.dart';
part 'model/model-agent_history.dart';
part 'model/model-call_list.dart';
part 'model/model-channel_list.dart';
part 'model/model-peer.dart';
part 'model/model-peer_list.dart';
part 'model/model-user_status_list.dart';

const String _libraryName = 'callflowcontrol.model';
