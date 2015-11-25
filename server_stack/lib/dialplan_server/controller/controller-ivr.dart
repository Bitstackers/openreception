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
  final Logger _log = new Logger ('$_libraryName.Ivr');

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
  Future<shelf.Response> get(shelf.Request request) async {
    int menuId;
    String idParam;
    try {
      idParam = shelf_route.getPathParameter(request, 'id');

      menuId = int.parse(idParam);
    } on FormatException {
      _log.warning('Non-numeric parameter $idParam');
      return _clientError('Non-numeric parameter $idParam');
    }

    try {
      return _okJson(await _ivrStore.get(menuId)..id = menuId);
    } on storage.NotFound {
      return _notFound('No menu with id $menuId');
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
    final int menuId = int.parse(shelf_route.getPathParameter(request, 'id'));

    return _okJson(await _ivrStore.remove(menuId));
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
