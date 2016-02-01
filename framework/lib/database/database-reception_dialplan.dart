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

part of openreception.database;

class ReceptionDialplan implements Storage.ReceptionDialplan {
  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  ReceptionDialplan(this._connection);

  /**
   *
   */
  Future<Iterable<Model.ReceptionDialplan>> list() async {
    String sql = '''
SELECT
 extension,
 dialplan
FROM
  reception_dialplans''';

    try {
      return (await _connection.query(sql)).map((row) => Model.ReceptionDialplan
          .decode(row.dialplan)..extension = row.extension);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> get(String extension) async {
    String sql = '''
SELECT
  extension,
  dialplan
FROM
  reception_dialplans
WHERE
  extension = @extension''';

    final Map parameters = {'extension': extension};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No diaplan with extension: $extension');
      }

      return Model.ReceptionDialplan.decode(rows.first.dialplan)
        ..extension = rows.first.extension;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> update(Model.ReceptionDialplan rdp) async {
    String sql = '''
UPDATE
  reception_dialplans
SET
  dialplan = @dialplan,
  extension = @extension
WHERE
  extension = @extension''';

    final Map parameters = {
      'extension': rdp.extension,
      'dialplan': rdp.toJson()
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('User not updated');
      }

      return rdp;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> create(Model.ReceptionDialplan rdp) async {
    String sql = '''
INSERT INTO
  reception_dialplans
    (extension, dialplan)
VALUES
    (@extension, @dialplan)
RETURNING
  extension''';

    final Map parameters = {
      'extension': rdp.extension,
      'dialplan': rdp.toJson()
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('User not created');
      }

      rdp.extension = rows.first.extension;
      return rdp;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future remove(String extension) async {
    String sql = '''
DELETE FROM
  reception_dialplans
WHERE
  extension = @extension''';

    final Map parameters = {'extension': extension};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No dialplan with extension $extension');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
