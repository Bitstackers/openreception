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
 * Ivr menu controller class.
 */
class Ivr {
  final database.Ivr _ivrStore;
  final Logger _log = new Logger('$_libraryName.Ivr');

  /**
   *
   */
  Ivr(this._ivrStore);

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

    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/ivr_menus/${menu.name}.xml';

    _log.fine('Deploying new dialplan to file $xmlFilePath');
    new File(xmlFilePath).writeAsString(dialplanTools.generateXmlFromIvr(menu));

    return _okJson(menu);
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
