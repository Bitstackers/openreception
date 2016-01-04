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

part of openreception.dialplan_server.controller;

/**
 * ReceptionDialplan controller class.
 */
class ReceptionDialplan {
  final database.ReceptionDialplan _receptionDialplanStore;
  final dialplanTools.DialplanCompiler compiler;
  final Logger _log = new Logger('$_libraryName.ReceptionDialplan');
  esl.Connection _eslClient;

  /**
   *
   */
  ReceptionDialplan(this._receptionDialplanStore, this.compiler) {
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
      return _notFound({});
    }

    return errors.isEmpty ? _okJson({}) : _clientError(errors);
  }

  /**
   *
   */
  Future<shelf.Response> create(shelf.Request request) async {
    final model.ReceptionDialplan rdp = model.ReceptionDialplan
        .decode(JSON.decode(await request.readAsString()));

    return _okJson(await _receptionDialplanStore.create(rdp));
  }

  /**
   *
   */
  Future<shelf.Response> deploy(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');
    final int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    model.ReceptionDialplan rdp;
    try {
      rdp = await _receptionDialplanStore.get(extension);
    } on storage.NotFound {
      return _notFound('No dialplan with extension $extension');
    }
    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/dialplan/receptions/$extension.xml';

    _log.fine('Deploying new dialplan to file $xmlFilePath');
    await new File(xmlFilePath)
        .writeAsString(compiler.dialplanToXml(rdp, rid));

    Iterable<model.Voicemail> voicemailAccounts =
        rdp.allActions.where((a) => a is model.Voicemail);

    voicemailAccounts.forEach((vm) async {
      final String vmFilePath = '${config.dialplanserver.freeswitchConfPath}'
          '/directory/voicemail/${vm.vmBox}.xml';

      _log.fine('Deploying voicemail account ${vm.vmBox} to file $vmFilePath');
      await new File(vmFilePath)
          .writeAsString(compiler.voicemailToXml(vm));
    });

    return _okJson(rdp);
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');

    try {
      return _okJson(await _receptionDialplanStore.get(extension));
    } on storage.NotFound {
      return _notFound('No dialplan with extension $extension');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      _okJson((await _receptionDialplanStore.list()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> reloadConfig(shelf.Request request) async {

    shelf.Response logAndReturn (esl.Response response) {
      final msg = 'Failed to reload: PBX response: ${response.rawBody}';
      _log.shout(msg);
      return _serverError(msg);
    }

    return _eslClient.api('reloadxml').then((eslResponse) =>
        eslResponse.status != esl.Response.OK
        ? logAndReturn(eslResponse)
        : _okJson({}));
  }

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final String extension = shelf_route.getPathParameter(request, 'extension');

    try {
      return _okJson(await _receptionDialplanStore.remove(extension));
    } on storage.NotFound {
      return _notFound('No dialplan with extension $extension');
    }
  }

  /**
   *
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final model.ReceptionDialplan rdp = model.ReceptionDialplan
        .decode(JSON.decode(await request.readAsString()));
    return _okJson(await _receptionDialplanStore.update(rdp));
  }


/**
 * ESL client setup
 */
Future _connectESLClient() async {
  Duration period = new Duration(seconds: 3);
  final String hostname = config.callFlowControl.eslConfig.hostname;
  final String password = config.callFlowControl.eslConfig.password;

  final int port = config.callFlowControl.eslConfig.port;

  // Reconnect;
  _eslClient = new esl.Connection();
  _eslClient.onDone = _connectESLClient;

  Future authenticate(esl.Connection client) =>
      client.authenticate(password).then((reply) {
        if (reply.status != esl.Reply.OK) {
          _log.shout('ESL Authentication failed - exiting');
          throw new StateError('ESL Authentication failed');
        }
      });

  _eslClient.requestStream.listen((packet) async {
    switch (packet.contentType) {
      case (esl.ContentType.Auth_Request):
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
}


