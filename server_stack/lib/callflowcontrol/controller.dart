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

library openreception.call_flow_control_server.controller;

import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:logging/logging.dart';

import 'package:esl/esl.dart' as ESL;
import 'package:openreception_framework/model.dart' as ORModel;

import 'model/model.dart' as Model;
import 'configuration.dart' as json;
import '../configuration.dart';

part 'controller/controller-client_notifier.dart';
part 'controller/controller-pbx.dart';
part 'controller/controller-state.dart';

const String libraryName = 'callflowcontrol.controller';
