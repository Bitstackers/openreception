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

part of openreception.database;

class Ivr implements Storage.Ivr {
  ///Logger
  final Logger _log = new Logger('${libraryName}.Ivr');

  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor.
   */
  Ivr(this._connection);

  /**
   *
   */
  Future<Iterable<Model.IvrMenu>> list() {
    String sql = '''
  SELECT 
     id, menu
  FROM
     ivr_menus''';

    return _connection.query(sql).then((Iterable rows) =>
        rows.map((row) => Model.IvrMenu.decode(row.menu)..id = row.id));
  }

  /**
   *
   */
  Future<Model.IvrMenu> get(int menuId) {
    String sql = '''
  SELECT 
     id, menu
  FROM
     ivr_menus
  WHERE
     id=@id''';

    Map parameters = {'id': menuId};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (Model.IvrMenu.decode(rows.first.menu)..id = rows.first.id)
            : throw new Storage.NotFound('No IVR menu with id $menuId'));
  }

  /**
   *
   */
  Future<Model.IvrMenu> update(Model.IvrMenu menu) {
    String sql = '''
    UPDATE ivr_menus
    SET menu=@menu
    WHERE id=@id;
  ''';

    Map parameters = {'id': menu.id, 'menu': menu.toJson()};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (menu..id = rows.first.id)
            : throw new Storage.SaveFailed(''));
  }

  /**
   *
   */
  Future<Model.IvrMenu> create(Model.IvrMenu menu) {
    String sql = '''
    INSERT INTO ivr_menus (menu)
    VALUES (@menu)
    RETURNING id''';

    Map parameters = {'menu': menu.toJson()};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (menu..id = rows.first.id)
            : throw new Storage.SaveFailed(''));
  }

  /**
   *
   */
  Future remove(int menuId) {
    String sql = '''
    DELETE FROM ivr_menus
    WHERE id = @id''';

    Map parameters = {'id': menuId};

    return _connection.execute(sql, parameters).then((int rowAffected) =>
        rowAffected == 1
            ? 0
            : throw new Storage.NotFound('No menu with id $menuId'));
  }
}
