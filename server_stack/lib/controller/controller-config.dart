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

library openreception.server.controller.config;

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;

import 'package:openreception.framework/keys.dart' as key;
import 'package:openreception.framework/model.dart' as model;

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/response_utils.dart';

class Config {
  final Logger _log = new Logger('controller.config');

  model.ClientConfiguration clientConfig = new model.ClientConfiguration.empty()
    ..authServerUri = config.configserver.authServerUri
    ..calendarServerUri = config.configserver.calendarServerUri
    ..callFlowServerUri = config.configserver.callFlowControlUri
    ..cdrServerUri = config.configserver.cdrServerUri
    ..contactServerUri = config.configserver.contactServerUri
    ..dialplanServerUri = config.configserver.dialplanServerUri
    ..hideInboundCallerId = config.hideInboundCallerId
    ..messageServerUri = config.configserver.messageServerUri
    ..myIdentifiers = config.myIdentifiers
    ..notificationServerUri = config.configserver.notificationServerUri
    ..notificationSocketUri = config.configserver.notificationSocketUri
    ..receptionServerUri = config.configserver.receptionServerUri
    ..systemLanguage = config.systemLanguage
    ..userServerUri = config.configserver.userServerUri;

  /**
   *
   */
  shelf.Response get(shelf.Request request) => okJson(clientConfig);

  /**
   *
   */
  Future<shelf.Response> register(shelf.Request request) async {
    Uri uri;
    String type;

    try {
      Map body = JSON.decode(await request.readAsString());
      type = body['type'];
      if (type == null || type.isEmpty) {
        throw new FormatException('Bad value of type: $type');
      }
      if (body['uri'] == null) {
        throw new FormatException('Bad value of uri: $uri');
      }

      uri = Uri.parse(body['uri']);
    } on FormatException catch (e) {
      return clientError('Bad parameters: $e');
    }

    switch (type) {
      case key.authentication:
        clientConfig.authServerUri = uri;
        break;
      case key.calendar:
        clientConfig.calendarServerUri = uri;
        break;
      case key.callflow:
        clientConfig.callFlowServerUri = uri;
        break;
      case key.cdr:
        clientConfig.cdrServerUri = uri;
        break;
      case key.contact:
        clientConfig.contactServerUri = uri;
        break;
      case key.dialplan:
        clientConfig.dialplanServerUri = uri;
        break;
      case key.message:
        clientConfig.messageServerUri = uri;
        break;
      case key.notification:
        clientConfig.notificationServerUri = uri;
        break;
      case key.notificationSocket:
        clientConfig.notificationSocketUri = uri;
        break;
      case key.reception:
        clientConfig.receptionServerUri = uri;
        break;
      case key.user:
        clientConfig.userServerUri = uri;
        break;
      default:
        _log.warning('Uknown type of registration: $type');
    }

    return okJson({});
  }
}
