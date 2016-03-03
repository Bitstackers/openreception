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

library openreception.cdr_server.controller;

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:openreception_framework/filestore.dart' as database;
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/util.dart' as util;

part 'controller-cdr.dart';

/**
 *
 */
shelf.Response _okJson(Map body) => new shelf.Response.ok(body);

/**
 *
 */
shelf.Response _clientError(String reason) =>
    new shelf.Response(400, body: reason);
