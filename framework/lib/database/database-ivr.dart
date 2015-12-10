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
     name, menu
  FROM
     ivr_menus''';

    return _connection
        .query(sql)
        .then((Iterable rows) =>
            rows.map((row) => Model.IvrMenu.decode(row.menu)..name = row.name))
        .catchError((error, stackTrace) {
      _log.severe('sql:$sql', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   *
   */
  Future<Model.IvrMenu> get(String menuName) async {
    String sql = '''
  SELECT 
     name, menu
  FROM
     ivr_menus
  WHERE
     name=@name''';

    Map parameters = {'name': menuName};

    try {
      final Iterable rows = await _connection.query(sql, parameters);


      if (rows.length != 1) {
        throw new Storage.NotFound();
      }
      return Model.IvrMenu.decode(rows.first.menu)..name = rows.first.name;
    } on Storage.NotFound {
      throw new Storage.NotFound('No IVR menu with name $menuName');
    } catch (error, stackTrace) {
      final msg = 'Failed to retrieve menu sql:$sql parameters:$parameters';
      _log.severe(msg, error, stackTrace);

      throw new Storage.ServerError(msg);
    }
  }

  /**
   *
   */
  Future<Model.IvrMenu> update(Model.IvrMenu menu) async {
    String sql = '''
    UPDATE ivr_menus
    SET menu=@menu
    WHERE name=@name;
  ''';

    Map parameters = {'name': menu.name, 'menu': menu.toJson()};

    try {
      final int affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows != 1) {
        throw new Storage.SaveFailed();
      }

      return menu;
    } catch (error, stackTrace) {
      final msg = 'Failed to update menu sql:$sql parameters:$parameters';
      _log.severe(msg, error, stackTrace);

      throw new Storage.ServerError(msg);
    }
  }

  /**
   *
   */
  Future<Model.IvrMenu> create(Model.IvrMenu menu) {
    String sql = '''
    INSERT INTO ivr_menus (name, menu)
    VALUES (@name, @menu)
    RETURNING name''';

    Map parameters = {'name': menu.name, 'menu': menu.toJson()};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (menu..name = rows.first.name)
            : throw new Storage.SaveFailed(''));
  }

  /**
   *
   */
  Future remove(String menuName) {
    String sql = '''
    DELETE FROM ivr_menus
    WHERE name = @name''';

    Map parameters = {'name': menuName};

    return _connection.execute(sql, parameters).then((int rowAffected) =>
        rowAffected == 1
            ? 0
            : throw new Storage.NotFound('No menu with name $menuName'));
  }
}
