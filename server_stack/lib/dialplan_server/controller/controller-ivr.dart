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

part of openreception.server.controller.dialplan;

Future<List<String>> _writeVoicemailfiles(
        Iterable<model.Voicemail> vms,
        dialplanTools.DialplanCompiler compiler,
        Logger _log,
        String confPath) async =>
    await Future.wait(
        vms.map((vm) => _writeVoicemailfile(vm, compiler, _log, confPath)));

Future<String> _writeVoicemailfile(
    model.Voicemail vm,
    dialplanTools.DialplanCompiler compiler,
    Logger _log,
    String confPath) async {
  final String vmFilePath = confPath + '/directory/voicemail/${vm.vmBox}.xml';

  _log.fine('Deploying voicemail account ${vm.vmBox} to file $vmFilePath');
  await new File(vmFilePath).writeAsString(compiler.voicemailToXml(vm));

  return vmFilePath;
}

/**
 * Ivr menu controller class.
 */
class Ivr {
  final storage.Ivr _ivrStore;
  final dialplanTools.DialplanCompiler compiler;
  final service.Authentication _authService;
  final String fsConfPath;
  final Logger _log = new Logger('$_libraryName.Ivr');

  Future<List<String>> _writeIvrfile(model.IvrMenu menu,
      dialplanTools.DialplanCompiler compiler, Logger _log) async {
    final String xmlFilePath = fsConfPath + '/ivr_menus/${menu.name}.xml';

    final List<String> generatedFiles = new List<String>.from([xmlFilePath]);

    _log.fine('Deploying new dialplan to file $xmlFilePath');
    new File(xmlFilePath).writeAsString(compiler.ivrToXml(menu));

    Iterable<model.Voicemail> voicemailAccounts =
        menu.allActions.where((a) => a is model.Voicemail);

    generatedFiles.addAll((await _writeVoicemailfiles(
        voicemailAccounts, compiler, _log, fsConfPath)));

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
  Ivr(this._ivrStore, this.compiler, this._authService, this.fsConfPath);

  /**
   *
   */
  Future<shelf.Response> create(shelf.Request request) async {
    final model.IvrMenu ivrMenu =
        model.IvrMenu.decode(JSON.decode(await request.readAsString()));

    model.User user;
    try {
      user = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }

    return okJson(await _ivrStore.create(ivrMenu, user));
  }

  /**
   *
   */
  Future<shelf.Response> deploy(shelf.Request request) async {
    final String menuName = shelf_route.getPathParameter(request, 'name');

    final model.IvrMenu menu = await _ivrStore.get(menuName);

    return okJson(await _writeIvrfile(menu, compiler, _log));
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    final String menuName = shelf_route.getPathParameter(request, 'name');

    try {
      return okJson(await _ivrStore.get(menuName));
    } on storage.NotFound {
      return notFound('No menu named $menuName');
    }
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async =>
      okJson((await _ivrStore.list()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final String menuName = shelf_route.getPathParameter(request, 'name');

    model.User user;
    try {
      user = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server', e, s);
      return authServerDown();
    }
    return okJson(await _ivrStore.remove(menuName, user));
  }

  /**
   *
   */
  Future<shelf.Response> update(shelf.Request request) async {
    final model.IvrMenu ivrMenu =
        model.IvrMenu.decode(JSON.decode(await request.readAsString()));

    model.User user;
    try {
      user = await _authService.userOf(tokenFrom(request));
    } catch (e, s) {
      _log.warning('Could not connect to auth server');
      return authServerDown();
    }
    return okJson(await _ivrStore.update(ivrMenu, user));
  }

  /**
   *
   */
  Future<shelf.Response> history(shelf.Request request) async =>
      okJson((await _ivrStore.changes()).toList(growable: false));

  /**
   *
   */
  Future<shelf.Response> objectHistory(shelf.Request request) async {
    final String name = shelf_route.getPathParameter(request, 'name');

    if (name == null || name.isEmpty) {
      return clientError('Bad menu name: $name');
    }

    return okJson((await _ivrStore.changes(name)).toList(growable: false));
  }
}
