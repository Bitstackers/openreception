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

library openreception.call_flow_control_server.router;

import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';

import '../configuration.dart';
import '../response_utils.dart';

import 'controller.dart' as Controller;
import 'model/model.dart' as Model;

import 'package:openreception.framework/pbx-keys.dart';
import 'package:openreception.framework/storage.dart' as ORStorage;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception.framework/service.dart' as Service;
import 'package:openreception.framework/service-io.dart' as Service_IO;
import 'package:openreception.framework/model.dart' as ORModel;
import 'package:openreception.framework/event.dart' as OREvent;

import 'package:logging/logging.dart';
import 'package:esl/esl.dart' as ESL;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

//part 'router/handler-user_state.dart';
part 'router/handler-call.dart';
part 'router/handler-channel.dart';

const String libraryName = "callflowcontrol.router";
final Logger log = new Logger(libraryName);

Controller.State _stateController;
Controller.ClientNotifier _notififer;

const Map<String, String> corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

Service.Authentication authService = null;
Service.RESTUserStore _userService;
Service.NotificationService notification = null;

shelf.Middleware checkAuthentication =
    shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);

/**
     * Validate a token by looking it up on the authentication server.
     */
Future<shelf.Response> _lookupToken(shelf.Request request) async {
  var token = request.requestedUri.queryParameters['token'];

  try {
    await authService.validate(token);
  } on storage.NotFound {
    return new shelf.Response.forbidden('Invalid token');
  } on io.SocketException {
    return new shelf.Response.internalServerError(
        body: 'Cannot reach authserver');
  } catch (error, stackTrace) {
    log.severe('Authentication validation lookup failed: $error:$stackTrace');

    return new shelf.Response.internalServerError(body: error.toString());
  }

  /// Do not intercept the request, but let the next handler take care of it.
  return null;
}

Future<io.HttpServer> start(
    {String hostname: '0.0.0.0',
    int port: 4242,
    authUri: null,
    notificationUri: null}) {
  _stateController = new Controller.State();
  authService = new Service.Authentication(
      authUri, config.callFlowControl.serverToken, new Service_IO.Client());

  Controller.ActiveRecording _activeRecordingController =
      new Controller.ActiveRecording();

  log.info('Starting client notifier');

  notification = new Service.NotificationService(notificationUri,
      config.callFlowControl.serverToken, new Service_IO.Client());

  _notififer = new Controller.ClientNotifier(notification)
    ..listenForCallEvents(Model.CallList.instance);

  _userService = new Service.RESTUserStore(config.userServer.externalUri,
      config.callFlowControl.serverToken, new Service_IO.Client());

  Controller.Peer _peerController = new Controller.Peer(Model.peerlist);

  var router = shelf_route.router()
        ..get('/peer', _peerController.list)
        ..get('/peer/{peerid}', _peerController.get)
        ..get('/call/{callid}', Call.get)
        ..post('/call/{callid}', Call.update)
        ..delete('/call/{callid}', Call.remove)
        ..get('/call', Call.list)
        ..post('/state/reload', _stateController.reloadAll)
        ..get('/channel', Channel.list)
        ..get('/channel/{chanid}', Channel.get)
        ..get('/activerecording', _activeRecordingController.list)
        ..get('/activerecording/{cid}', _activeRecordingController.get)
        ..get('/channel', Channel.list)
        ..post('/call/{callid}/hangup', Call.hangupSpecific)
        ..post('/call/{callid}/pickup', Call.pickup)
        ..post('/call/{callid}/park', Call.park)
        ..post(
            '/call/originate/{extension}/dialplan/{dialplan}'
            '/reception/{rid}/contact/{cid}',
            Call.originate)
        ..post(
            '/call/originate/{extension}/dialplan/{dialplan}'
            '/reception/{rid}/contact/{cid}/call/{callId}',
            Call.originate)
        ..post(
            '/call/originate/{extension}@{host}:{port}/dialplan/{dialplan}'
            '/reception/{rid}/contact/{cid}',
            Call.originate)
        ..post(
            '/call/originate/{extension}@{host}:{port}/dialplan/{dialplan}'
            '/reception/{rid}/contact/{cid}/call/{callId}',
            Call.originate)
        ..post('/call/{aleg}/transfer/{bleg}', Call.transfer)
      //..post('/call/reception/{rid}/record', Call.recordSound)
      ;

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  log.fine('Using server on $authUri as authentication backend');
  log.fine('Using server on $notificationUri as notification backend');
  log.fine('Accepting incoming REST requests on http://$hostname:$port');
  log.fine('Serving routes:');
  shelf_route.printRoutes(router, printer: (String item) => log.fine(item));

  return shelf_io.serve(handler, hostname, port);
}
