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

final Map client_config =
  {
      "callFlowServerURI"     : config.callFlowServerUri.toString(),
      "receptionServerURI"    : config.receptionServerUri.toString(),
      "contactServerURI"      : config.contactServerUri.toString(),
      "messageServerURI"      : config.messageServerUri.toString(),
      "logServerURI"          : config.logServerUri.toString(),
      "authServerURI"         : config.authServerUri.toString(),
      "systemLanguage"        : config.systemLanguage,
      "notificationServerUri" : config.notificationServerUri.toString(),

      "notificationSocket": {
          "interface": config.notificationSocketUri.toString(),
          "reconnectInterval": 2000
      }
  };

shelf.Response getBobConfig(shelf.Request request) =>
  new shelf.Response.ok(JSON.encode(client_config));

shelf.Response send404(shelf.Request request) {
  return new shelf.Response.notFound(JSON.encode({"error" : "Not Found"}));
}


