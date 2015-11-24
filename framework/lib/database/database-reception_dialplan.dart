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
     id, dialplan
  FROM
     reception_dialplans''';

    return _connection.query(sql).then((Iterable rows) =>
        rows.map((row) => Model.ReceptionDialplan.decode(row.dialplan)..id = row.id));
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> get(int rdpId) {
    String sql = '''
  SELECT 
     id, dialplan
  FROM
     reception_dialplans
  WHERE
     id=@id''';

    Map parameters = {'id': rdpId};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (Model.ReceptionDialplan.decode(rows.first.dialplan)..id = rows.first.id)
            : throw new Storage.NotFound('No dialplan with id $rdpId'));
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> update(Model.ReceptionDialplan rdp) {
    String sql = '''
    UPDATE reception_dialplans
    SET dialplan=@dialplan
    WHERE id=@id;
  ''';

    Map parameters = {'id': rdp.id, 'dialplan': rdp.toJson()};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (rdp..id = rows.first.id)
            : throw new Storage.SaveFailed(''));
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> create(Model.ReceptionDialplan dialplan) {
    String sql = '''
    INSERT INTO reception_dialplans (dialplan)
    VALUES (@dialplan)
    RETURNING id''';

    Map parameters = {'dialplan': dialplan.toJson()};

    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length == 1
            ? (dialplan..id = rows.first.id)
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
