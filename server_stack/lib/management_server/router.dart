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

library openreception.management_server.router;

import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart' as json;
import '../configuration.dart';
import 'controller/dialplan.dart';
import 'utilities/http.dart';
import 'database.dart';
import 'package:openreception_framework/httpserver.dart' as orf_http;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

final Pattern _anyThing = new UrlPattern(r'/(.*)');

/// Dialplan handling.
final Pattern _dialplanUrl = new UrlPattern(r'/reception/(\d+)/dialplan');
final Pattern _dialplanCompileUrl =
    new UrlPattern(r'/reception/(\d+)/dialplan/compile');
final Pattern _ivrUrl = new UrlPattern(r'/reception/(\d+)/ivr');
final Pattern _audiofilesUrl = new UrlPattern(r'/reception/(\d+)/audiofiles');
final Pattern _receptionRecordUrl = new UrlPattern(r'/reception/(\d+)/record');
final Pattern _playlistUrl = new UrlPattern(r'/playlist');
final Pattern _playlistIdUrl = new UrlPattern(r'/playlist/(\d+)');

final Pattern _dialplanTemplateUrl = new UrlPattern(r'/dialplantemplate');

//This resource is only meant to be used, in the time where data is being migrated over.
final Pattern _receptionContactIdMoveUrl =
    new UrlPattern(r'/reception/(\d+)/contact/(\d+)/newContactId/(\d+)');

final List<Pattern> Serviceagents = [
  _dialplanUrl,
  _dialplanCompileUrl,
  _ivrUrl,
  _audiofilesUrl,
  _playlistUrl,
  _playlistIdUrl,
  _receptionContactIdMoveUrl
];

DialplanController _dialplan;

Service.NotificationService Notification = null;

void connectNotificationService() {
  Notification = new Service.NotificationService(
      json.config.notificationServer, Configuration.authServer.serverToken, new Service_IO.Client());
}

Router setupRoutes(HttpServer server, json.Configuration config) =>
    new Router(server)
  ..filter(matchAny(Serviceagents), (HttpRequest req) =>
      authorizedRole(req, json.config.authUrl, ['Service agent', 'Administrator']))
  ..serve(_receptionRecordUrl, method: HttpMethod.POST)
      .listen(_dialplan.recordSound)
  ..serve(_receptionRecordUrl, method: HttpMethod.DELETE)
      .listen(_dialplan.deleteSoundFile)
  ..serve(_dialplanUrl, method: HttpMethod.GET).listen(_dialplan.getDialplan)
  ..serve(_dialplanUrl, method: HttpMethod.POST).listen(_dialplan.updateDialplan)
  ..serve(_dialplanCompileUrl, method: HttpMethod.POST)
      .listen(_dialplan.compileDialplan)
  ..serve(_dialplanTemplateUrl, method: HttpMethod.GET)
      .listen(_dialplan.getTemplates)
  ..serve(_ivrUrl, method: HttpMethod.GET).listen(_dialplan.getIvr)
  ..serve(_ivrUrl, method: HttpMethod.POST).listen(_dialplan.updateIvr)
  ..serve(_playlistUrl, method: HttpMethod.GET).listen(_dialplan.getPlaylists)
  ..serve(_playlistUrl, method: HttpMethod.PUT).listen(_dialplan.createPlaylist)
  ..serve(_playlistIdUrl, method: HttpMethod.GET).listen(_dialplan.getPlaylist)
  ..serve(_playlistIdUrl, method: HttpMethod.POST)
      .listen(_dialplan.updatePlaylist)
  ..serve(_playlistIdUrl, method: HttpMethod.DELETE)
      .listen(_dialplan.deletePlaylist)
  ..serve(_audiofilesUrl, method: HttpMethod.GET)
      .listen(_dialplan.getAudiofileList)
  ..serve(_anyThing, method: HttpMethod.OPTIONS).listen(orf_http.preFlight)
  ..defaultStream.listen(orf_http.page404);

void setupControllers(Database db, json.Configuration config) {
  _dialplan = new DialplanController(db, json.config);
}
