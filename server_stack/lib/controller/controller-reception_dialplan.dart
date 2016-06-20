/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.server.controller.dialplan;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:logging/logging.dart';

import 'package:esl/esl.dart' as esl;
import 'package:openreception.framework/filestore.dart' as database;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.framework/dialplan_tools.dart' as dialplanTools;

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/response_utils.dart';
import 'package:openreception.server/controller/controller-ivr.dart';

/**
 * ReceptionDialplan controller class.
 */
class ReceptionDialplan {
  final database.ReceptionDialplan _receptionDialplanStore;
  final database.Reception _receptionStore;
  final dialplanTools.DialplanCompiler compiler;
  final String fsConfPath;
  final Ivr _ivrController;
  final service.Authentication _authService;

  final Logger _log = new Logger('server.controller.dialplan');
  esl.Connection _eslClient;
  final EslConfig eslConfig;

  /**
   *
   */
  ReceptionDialplan(
      this._receptionDialplanStore,
      this._receptionStore,
      this._authService,
      this.compiler,
      this._ivrController,
      this.fsConfPath,
      this.eslConfig) {
    _connectESLClient();
  }

  /**
   *
   */
  Future<shelf.Response> analyze(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');

    List<String> collectErrors(model.ReceptionDialplan rdp) =>
        throw new UnimplementedError();

    List<String> errors = [];
    try {
      errors = collectErrors(await _receptionDialplanStore.get(extension));
    } on FormatException {
      /// Could not parse dialplan
    } on storage.NotFound {
      return notFound({});
    }

    return errors.isEmpty ? okJson({}) : clientErrorJson(errors);
  }

  /**
   *
   */
  Future<shelf.Response> create(shelf.Request request) async {
    final model.ReceptionDialplan rdp = model.ReceptionDialplan
        .decode(JSON.decode(await request.readAsString()));

    model.User user;
    try {
      user = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }

    return okJson(await _receptionDialplanStore.create(rdp, user));
  }

  /**
   *
   */
  Future<shelf.Response> deploy(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    model.ReceptionDialplan rdp;
    model.Reception r;
    try {
      rdp = await _receptionDialplanStore.get(extension);
      r = await _receptionStore.get(rid);
    } on storage.NotFound {
      return notFound('No dialplan with extension $extension');
    }
    final String xmlFilePath =
        fsConfPath + '/dialplan/receptions/$extension.xml';
    final List<String> generatedFiles = new List<String>.from([xmlFilePath]);

    _log.fine('Deploying new dialplan to file $xmlFilePath');
    await new File(xmlFilePath).writeAsString(compiler.dialplanToXml(rdp, r));

    /// Generate associated voicemail acccounts.
    final Iterable<model.Voicemail> voicemailAccounts =
        rdp.allActions.where((a) => a is model.Voicemail);

    generatedFiles.addAll((await writeVoicemailfiles(
        voicemailAccounts, compiler, _log, fsConfPath)));

    // /// Generate associated IVR menus.
    Iterable<model.Ivr> ivrMenus = rdp.allActions.where((a) => a is model.Ivr);

    generatedFiles.addAll(await _ivrController.writeIvrfiles(
        ivrMenus.map((menuAction) => menuAction.menuName) as Iterable<String>,
        compiler,
        _log));

    return okJson(generatedFiles);
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');

    try {
      return okJson(await _receptionDialplanStore.get(extension));
    } on storage.NotFound {
      return notFound('No dialplan with extension $extension');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      okJson((await _receptionDialplanStore.list()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> reloadConfig(shelf.Request request) async {
    shelf.Response logAndReturn(esl.Response response) {
      final msg = 'Failed to reload: PBX response: ${response.rawBody}';
      _log.shout(msg);
      return serverError(msg);
    }

    return await _eslClient.api('reloadxml').then((eslResponse) =>
        eslResponse.status != esl.Response.ok
            ? logAndReturn(eslResponse)
            : okJson({}));
  }

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');
    model.User user;

    try {
      user = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }

    try {
      return okJson(await _receptionDialplanStore.remove(extension, user));
    } on storage.NotFound {
      return notFound('No dialplan with extension $extension');
    }
  }

  /**
   *
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final model.ReceptionDialplan rdp = model.ReceptionDialplan
        .decode(JSON.decode(await request.readAsString()));

    model.User user;
    try {
      user = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }

    return okJson(await _receptionDialplanStore.update(rdp, user));
  }

/**
 * ESL client setup
 */
  Future _connectESLClient() async {
    Duration period = new Duration(seconds: 3);
    final String hostname = eslConfig.hostname;
    final String password = eslConfig.password;

    final int port = eslConfig.port;

    // Reconnect;
    _eslClient = new esl.Connection();
    _eslClient.onDone = _connectESLClient;

    Future authenticate(esl.Connection client) =>
        client.authenticate(password).then((reply) {
          if (reply.status != esl.Reply.ok) {
            _log.shout('ESL Authentication failed - exiting');
            throw new StateError('ESL Authentication failed');
          }
        });

    _eslClient.requestStream.listen((packet) async {
      switch (packet.contentType) {
        case (esl.ContentType.authRequest):
          _log.info('Connected to ${hostname}:${port}');
          await authenticate(_eslClient);
          break;

        default:
          break;
      }
    });
    _log.info('Connecting to ${hostname}:${port}');

    Future tryConnect() async {
      await _eslClient.connect(hostname, port).catchError((error, stackTrace) {
        if (error is SocketException) {
          _log.severe(
              'ESL Connection failed - reconnecting in ${period.inSeconds} seconds');
          new Timer(period, tryConnect);
        } else {
          _log.severe('Failed to connect to FreeSWITCH.', error, stackTrace);
        }
      });
    }

    await tryConnect();
  }

  /**
   *
   */
  Future<shelf.Response> history(shelf.Request request) async =>
      okJson((await _receptionDialplanStore.changes()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> objectHistory(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');

    if (extension == null || extension.isEmpty) {
      return clientError('Bad extension: $extension');
    }

    return okJson((await _receptionDialplanStore.changes(extension))
        .toList(growable: false));
  }
}
