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

library openreception.cdr_server.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart' as json;
import 'database.dart' as db;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/httpserver.dart';
import 'package:logging/logging.dart';

part 'router/cdr.dart';
part 'router/create_checkpoint.dart';
part 'router/get_checkpoint.dart';
part 'router/newcdr.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern cdrResource = new UrlPattern(r'/cdr');
final Pattern newcdrResource = new UrlPattern(r'/newcdr');
final Pattern checkpointResource = new UrlPattern(r'/checkpoint');

final List<Pattern> allUniqueUrls = [cdrResource, checkpointResource];

final Logger log = new Logger('cdrserver.router');

Router setup(HttpServer server) =>
  new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(json.config.authUrl))
    ..serve(cdrResource,    method: 'GET').listen(cdrHandler)
    ..serve(newcdrResource, method: 'POST').listen(insertCdrData)
    ..serve(checkpointResource, method: 'GET').listen(getCheckpoints)
    ..serve(checkpointResource, method: 'POST').listen(createCheckpoint)
    ..serve(anything,       method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);

