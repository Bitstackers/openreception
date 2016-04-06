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
import 'dart:io';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

import 'package:openreception_framework/keys.dart' as key;
import 'package:openreception_framework/model.dart' as model;

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/response_utils.dart';

class Config {
  final Logger _log = new Logger('controller.config');

  model.ClientConfiguration client_config =
      new model.ClientConfiguration.empty()
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
  shelf.Response get(shelf.Request request) => okJson(client_config);

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
        client_config.authServerUri = uri;
        break;
      case key.calendar:
        client_config.calendarServerUri = uri;
        break;
      case key.callflow:
        client_config.callFlowServerUri = uri;
        break;
      case key.cdr:
        client_config.cdrServerUri = uri;
        break;
      case key.contact:
        client_config.contactServerUri = uri;
        break;
      case key.dialplan:
        client_config.dialplanServerUri = uri;
        break;
      case key.message:
        client_config.messageServerUri = uri;
        break;
      case key.notification:
        client_config.notificationServerUri = uri;
        break;
      case key.notificationSocket:
        client_config.notificationSocketUri = uri;
        break;
      case key.user:
        client_config.userServerUri = uri;
        break;
      default:
        _log.warning('Uknown type of registration: $type');
    }

    return okJson({});
  }
}
