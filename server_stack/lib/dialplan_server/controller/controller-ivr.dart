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

Future<List<String>> _writeVoicemailfiles(Iterable<model.Voicemail> vms,
        dialplanTools.DialplanCompiler compiler, Logger _log) async =>
    await Future.wait(vms.map((vm) => _writeVoicemailfile(vm, compiler, _log)));

Future<String> _writeVoicemailfile(model.Voicemail vm,
    dialplanTools.DialplanCompiler compiler, Logger _log) async {
  final String vmFilePath = '${config.dialplanserver.freeswitchConfPath}'
      '/directory/voicemail/${vm.vmBox}.xml';

  _log.fine('Deploying voicemail account ${vm.vmBox} to file $vmFilePath');
  await new File(vmFilePath).writeAsString(compiler.voicemailToXml(vm));

  return vmFilePath;
}

/**
 * Ivr menu controller class.
 */
class Ivr {
  final database.Ivr _ivrStore;
  final dialplanTools.DialplanCompiler compiler;
  final Logger _log = new Logger('$_libraryName.Ivr');

  Future<List<String>> _writeIvrfile(model.IvrMenu menu,
      dialplanTools.DialplanCompiler compiler, Logger _log) async {
    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/ivr_menus/${menu.name}.xml';

    final List<String> generatedFiles = new List<String>.from([xmlFilePath]);

    _log.fine('Deploying new dialplan to file $xmlFilePath');
    new File(xmlFilePath).writeAsString(compiler.ivrToXml(menu));

    Iterable<model.Voicemail> voicemailAccounts =
        menu.allActions.where((a) => a is model.Voicemail);

    generatedFiles.addAll(
        (await _writeVoicemailfiles(voicemailAccounts, compiler, _log)));

    return generatedFiles;
  }

  Future<List<String>> _writeIvrfiles(Iterable<String> menuNames,
      dialplanTools.DialplanCompiler compiler, Logger _log) async {
    List<String> allFiles = new List<String>();

    Iterable written = await Future.wait(menuNames.map((menuName) async {
      final menu = await _ivrStore.get(menuName);

      return _writeIvrfile(menu, compiler, _log);
    }));

    written.forEach((Iterable<String> files) {
      allFiles.addAll(files);
    });

    return allFiles;
  }

  /**
   *
   */
  Ivr(this._ivrStore, this.compiler);

  /**
   *
   */
  Future<shelf.Response> create(shelf.Request request) async {
    final model.IvrMenu ivrMenu =
        model.IvrMenu.decode(JSON.decode(await request.readAsString()));

    return _okJson(await _ivrStore.create(ivrMenu));
  }

  /**
   *
   */
  Future<shelf.Response> deploy(shelf.Request request) async {
    final String menuName = shelf_route.getPathParameter(request, 'name');

    final model.IvrMenu menu = await _ivrStore.get(menuName);

    return _okJson(await _writeIvrfile(menu, compiler, _log));
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final String menuName = shelf_route.getPathParameter(request, 'name');

    try {
      return _okJson(await _ivrStore.get(menuName));
    } on storage.NotFound {
      return _notFound('No menu named $menuName');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      _okJson((await _ivrStore.list()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final String menuName = shelf_route.getPathParameter(request, 'name');

    return _okJson(await _ivrStore.remove(menuName));
  }

  /**
   *
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final model.IvrMenu ivrMenu =
        model.IvrMenu.decode(JSON.decode(await request.readAsString()));
    return _okJson(await _ivrStore.update(ivrMenu));
  }
}
