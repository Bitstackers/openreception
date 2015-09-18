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

part of openreception.configuration_server.router;

final ORModel.ClientConfiguration client_config =
  new ORModel.ClientConfiguration.empty()
    ..authServerUri = config.authServerUri
    ..callFlowServerUri = config.callFlowServerUri
    ..contactServerUri = config.contactServerUri
    ..messageServerUri = config.messageServerUri
    ..notificationServerUri = config.notificationServerUri
    ..notificationSocketUri = config.notificationSocketUri
    ..receptionServerUri = config.receptionServerUri
    ..systemLanguage = config.systemLanguage
    ..userServerUri = config.userServerUri;

shelf.Response getBobConfig(shelf.Request request) =>
  new shelf.Response.ok(JSON.encode(client_config));

shelf.Response send404(shelf.Request request) {
  return new shelf.Response.notFound(JSON.encode({"error" : "Not Found"}));
}


