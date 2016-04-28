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

library openreception.server.controller.call_flow;

import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:logging/logging.dart';

import 'package:esl/esl.dart' as ESL;
import 'package:openreception.framework/model.dart' as ORModel;
import 'package:openreception.framework/pbx-keys.dart';
import 'package:openreception.framework/service.dart' as ORService;
import 'package:openreception.framework/storage.dart' as ORStorage;

import 'package:openreception.server/response_utils.dart';
import 'package:openreception.server/callflowcontrol/model/model.dart' as Model;
import 'package:openreception.server/configuration.dart';

part 'controller/controller-active_recording.dart';
part 'controller/controller-client_notifier.dart';
part 'controller/controller-pbx.dart';
part 'controller/controller-peer.dart';
part 'controller/controller-state.dart';

const String libraryName = 'controller.call_flow';
