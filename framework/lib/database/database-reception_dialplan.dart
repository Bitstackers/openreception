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
  ///Logger
  final Logger _log = new Logger('${libraryName}.ReceptionDialplan');

  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor.
   */
  ReceptionDialplan(this._connection);

  /**
   *
   */
  Future<Iterable<Model.ReceptionDialplan>> list() {
    String sql = '''
  SELECT 
     id, extension, dialplan
  FROM
     reception_dialplans''';

    return _connection.query(sql).then((Iterable rows) =>
        rows.map((row) => Model.ReceptionDialplan.decode(row.dialplan)
          ..id = row.id
          ..extension = row.extension));
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> get(int rdpId) {
    String sql = '''
  SELECT 
     id, extension, dialplan
  FROM
     reception_dialplans
  WHERE
     id=@id''';

    Map parameters = {'id': rdpId};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (Model.ReceptionDialplan.decode(rows.first.dialplan)
              ..id = rows.first.id
              ..extension = rows.first.extension)
            : throw new Storage.NotFound('No dialplan with id $rdpId'));
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> update(Model.ReceptionDialplan rdp) {
    String sql = '''
    UPDATE reception_dialplans
    SET dialplan=@dialplan,
        extension=@extension
    WHERE id=@id;
  ''';

    Map parameters = {'id': rdp.id, 'extension': rdp.extension, 'dialplan': rdp.toJson()};

    return _connection.execute(sql, parameters).then((int rowsAffected) =>
        rowsAffected == 1 ? rdp : throw new Storage.SaveFailed(''));
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> create(Model.ReceptionDialplan rdp) {
    String sql = '''
    INSERT INTO reception_dialplans (extension, dialplan)
    VALUES (@extension, @dialplan)
    RETURNING id''';

    Map parameters = {'extension': rdp.extension, 'dialplan': rdp.toJson()};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (rdp..id = rows.first.id)
            : throw new Storage.SaveFailed(''));
  }

  /**
   *
   */
  Future remove(int rdpId) {
    String sql = '''
    DELETE FROM reception_dialplans
    WHERE id = @id''';

    Map parameters = {'id': rdpId};

    return _connection.execute(sql, parameters).then((int rowAffected) =>
        rowAffected == 1
            ? 0
            : throw new Storage.NotFound('No dialplan with id $rdpId'));
  }
}
