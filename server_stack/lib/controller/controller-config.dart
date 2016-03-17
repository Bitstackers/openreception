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

part of openreception.server.router.config;

final model.ClientConfiguration client_config =
    new model.ClientConfiguration.empty()
      ..authServerUri = config.configserver.authServerUri
      ..calendarServerUri = config.configserver.calendarServerUri
      ..callFlowServerUri = config.configserver.callFlowControlUri
      ..cdrServerUri = config.configserver.cdrServerUri
      ..contactServerUri = config.configserver.contactServerUri
      ..dialplanServerUri = config.configserver.dialplanServerUri
      ..messageServerUri = config.configserver.messageServerUri
      ..notificationServerUri = config.configserver.notificationServerUri
      ..notificationSocketUri = config.configserver.notificationSocketUri
      ..receptionServerUri = config.configserver.receptionServerUri
      ..systemLanguage = config.systemLanguage
      ..userServerUri = config.configserver.userServerUri;

shelf.Response getClientConfig(shelf.Request request) =>
    new shelf.Response.ok(JSON.encode(client_config));
