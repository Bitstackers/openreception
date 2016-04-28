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

library openreception.server.router.dialplan;

import 'dart:async';
import 'dart:io' as io;

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception.framework/service.dart' as Service;
import 'package:openreception.framework/service-io.dart' as Service_IO;
import 'package:openreception.framework/dialplan_tools.dart' as dialplanTools;

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/response_utils.dart';

import 'controller.dart' as controller;

final Logger _log = new Logger('dialplanserver.router');

Future<io.HttpServer> start(
    {String hostname: '0.0.0.0',
    int port: 4060,
    Uri authUri,
    String filepath: '',
    String playbackPrefix: '',
    String fsConfPath: '',
    EslConfig eslConfig}) async {
  final Service.Authentication _authService = new Service.Authentication(
      authUri, config.userServer.serverToken, new Service_IO.Client());

  /**
   * Validate a token by looking it up on the authentication server.
   */
  Future<shelf.Response> _lookupToken(shelf.Request request) async {
    var token = request.requestedUri.queryParameters['token'];

    try {
      await _authService.validate(token);
    } on storage.NotFound {
      return new shelf.Response.forbidden('Invalid token');
    } on io.SocketException {
      return new shelf.Response.internalServerError(
          body: 'Cannot reach authserver');
    } catch (error, stackTrace) {
      _log.severe(
          'Authentication validation lookup failed: $error:$stackTrace');

      return new shelf.Response.internalServerError(body: error.toString());
    }

    /// Do not intercept the request, but let the next handler take care of it.
    return null;
  }

  /**
   * Authentication middleware.
   */
  shelf.Middleware checkAuthentication = shelf.createMiddleware(
      requestHandler: _lookupToken, responseHandler: null);

  /**
   * Controllers.
   */

  final filestore.Ivr _ivrStore = new filestore.Ivr(path: filepath + '/ivr');
  final filestore.ReceptionDialplan _dpStore =
      new filestore.ReceptionDialplan(path: filepath + '/dialplan');

  final filestore.Reception _rStore =
      new filestore.Reception(path: filepath + '/reception');
  final filestore.User _userStore =
      new filestore.User(path: filepath + '/user');

  /// Setup dialplan tools.
  final dialplanTools.DialplanCompiler compiler =
      new dialplanTools.DialplanCompiler(new dialplanTools.DialplanCompilerOpts(
          goLive: config.dialplanserver.goLive,
          greetingDir: playbackPrefix,
          testNumber: config.dialplanserver.testNumber,
          testEmail: config.dialplanserver.testEmail,
          callerIdName: config.callFlowControl.callerIdName,
          callerIdNumber: config.callFlowControl.callerIdNumber));

  _log.info('Dialplan tools are ${compiler.option.goLive ? 'live ' : 'NOT live '
    'diverting all voicemails to ${compiler.option.testEmail} and directing '
    'all calls to ${compiler.option.testNumber}'}');

  final controller.Ivr ivrHandler =
      new controller.Ivr(_ivrStore, compiler, _authService, fsConfPath);
  final controller.ReceptionDialplan receptionDialplanHandler =
      new controller.ReceptionDialplan(_dpStore, _rStore, _authService,
          compiler, ivrHandler, fsConfPath, eslConfig);

  final controller.PeerAccount peerAccountHandler =
      new controller.PeerAccount(_userStore, compiler, fsConfPath);

  final router = shelf_route.router()
    ..post('/peeraccount/user/{uid}/deploy', peerAccountHandler.deploy)
    ..get('/peeraccount', peerAccountHandler.list)
    ..get('/peeraccount/{aid}', peerAccountHandler.get)
    ..delete('/peeraccount/{aid}', peerAccountHandler.remove)
    ..get('/ivr', ivrHandler.list)
    ..get('/ivr/{name}', ivrHandler.get)
    ..put('/ivr/{name}', ivrHandler.update)
    ..post('/ivr/{name}/deploy', ivrHandler.deploy)
    ..delete('/ivr/{name}', ivrHandler.remove)
    ..get('/ivr/{name}/history', ivrHandler.objectHistory)
    ..post('/ivr', ivrHandler.create)
    ..get('/ivr/history', ivrHandler.history)
    ..get('/receptiondialplan', receptionDialplanHandler.list)
    ..get('/receptiondialplan/{extension}', receptionDialplanHandler.get)
    ..put('/receptiondialplan/{extension}', receptionDialplanHandler.update)
    ..post('/receptiondialplan/reloadConfig',
        receptionDialplanHandler.reloadConfig)
    ..get('/receptiondialplan/{extension}/history',
        receptionDialplanHandler.objectHistory)
    ..delete('/receptiondialplan/{extension}', receptionDialplanHandler.remove)
    ..post('/receptiondialplan', receptionDialplanHandler.create)
    ..get('/receptiondialplan/history', receptionDialplanHandler.history)
    ..post('/receptiondialplan/{extension}/analyze',
        receptionDialplanHandler.analyze)
    ..post('/receptiondialplan/{extension}/deploy/{rid}',
        receptionDialplanHandler.deploy);

  final handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  _log.fine('Deploying generated xml files to $fsConfPath subdirs');
  _log.fine('Accepting incoming requests on $hostname:$port:');
  _log.fine('Using server on $authUri as authentication backend');

  shelf_route.printRoutes(router, printer: _log.fine);

  return await shelf_io.serve(handler, hostname, port);
}
