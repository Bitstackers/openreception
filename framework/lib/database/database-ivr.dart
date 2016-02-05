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
  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  Ivr(this._connection);

  /**
   *
   */
  Future<Iterable<Model.IvrMenu>> list() async {
    String sql = '''
  SELECT
     name, menu
  FROM
     ivr_menus''';

    try {
      final Iterable<PG.Row> rows = await _connection.query(sql);
      return rows.map((row) => Model.IvrMenu.decode(row.menu)..name = row.name);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
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

    final Map parameters = {'name': menuName};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No menu with name: $menuName');
      }

      return Model.IvrMenu.decode(rows.first.menu)..name = rows.first.name;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.IvrMenu> update(Model.IvrMenu menu) async {
    String sql = '''
UPDATE
  ivr_menus
SET
  menu = @menu
WHERE
  name = @name''';

    final Map parameters = {'name': menu.name, 'menu': menu.toJson()};

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('Menu not updated');
      }

      return menu;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.IvrMenu> create(Model.IvrMenu menu) async {
    String sql = '''
    INSERT INTO ivr_menus (name, menu)
    VALUES (@name, @menu)
    RETURNING name''';

    final Map parameters = {'name': menu.name, 'menu': menu.toJson()};

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Menu not created');
      }

      menu.name = rows.first.name;
      return menu;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future remove(String menuName) async {
    String sql = '''
    DELETE FROM ivr_menus
    WHERE name = @name''';

    final Map parameters = {'name': menuName};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No menu with uid: $menuName');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
