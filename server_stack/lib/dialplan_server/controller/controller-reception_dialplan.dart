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
  final Logger _log = new Logger('$_libraryName.ReceptionDialplan');

  /**
   *
   */
  ReceptionDialplan(this._receptionDialplanStore);

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

    final model.ReceptionDialplan rdp =
        await _receptionDialplanStore.get(extension);

    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/dialplan/receptions/$extension.xml';

    _log.fine('Deploying new dialplan to file $xmlFilePath');
    new File(xmlFilePath).writeAsString(dialplanTools.convertTextual(rdp, rid));

    Iterable<model.Voicemail> voicemailAccounts =
        rdp.allActions.where((a) => a is model.Voicemail);

    voicemailAccounts.forEach((vm) {
      final String vmFilePath = '${config.dialplanserver.freeswitchConfPath}'
      '/directory/voicemail/${vm.vmBox}.xml';

      _log.fine('Deploying voicemail account ${vm.vmBox} to file $vmFilePath');
      new File(vmFilePath).writeAsString(dialplanTools.convertVoicemail(vm));

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
}
