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

library openreception.dialplan_server.controller;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:logging/logging.dart';

import 'package:esl/esl.dart' as esl;
import 'package:openreception_framework/filestore.dart' as database;
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/dialplan_tools.dart' as dialplanTools;

import '../configuration.dart';
import '../response_utils.dart';

part 'controller/controller-ivr.dart';
part 'controller/controller-peer_account.dart';
part 'controller/controller-reception_dialplan.dart';

const String _libraryName = 'dialplan_server.controller';
