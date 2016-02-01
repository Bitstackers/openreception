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

class Reception implements Storage.Reception {
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  Reception(Connection this._connection);

  /**
   *
   */
  Future<Model.Reception> create(Model.Reception reception) async {
    String sql = '''
INSERT INTO
  receptions
    (organization_id, full_name, attributes,
     extradatauri, enabled, dialplan)
VALUES
    (@organization_id, @full_name, @attributes,
     @extradatauri, @enabled, @dialplan)
RETURNING
  id, last_check''';

    final Map parameters = {
      'organization_id': reception.organizationId,
      'full_name': reception.fullName,
      'attributes': JSON.encode(reception.attributes),
      'extradatauri':
          reception.extraData != null ? reception.extraData.toString() : '',
      'enabled': reception.enabled,
      'dialplan': reception.dialplan
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Reception not created');
      }

      reception
        ..ID = rows.first.id
        ..lastChecked = rows.first.last_check;
      return reception;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve a specific reception from the database identified
   * by its extension.
   * TODO(krc): This is actually an [Iterable] - make it so.
   */
  Future<Model.Reception> getByExtension(String extension) async {
    String sql = '''
SELECT
  id,
  full_name,
  attributes,
  enabled,
  organization_id,
  extradatauri,
  last_check,
  dialplan
FROM
  receptions
WHERE
  dialplan = @exten''';

    final Map parameters = {'exten': extension};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No reception with extension $extension');
      }

      return _rowToReception(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve the extension of a specific reception from the database
   * identified its ID.
   */
  Future<String> extensionOf(int receptionId) async {
    String sql = '''
SELECT
  dialplan
FROM
  receptions
WHERE
  id = @id''';

    try {
      Iterable rows = await _connection.query(sql);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No reception with if $receptionId');
      }

      return rows.first.dialplan;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve a specific reception from the database.
   */
  Future<Model.Reception> get(int receptionId) async {
    String sql = '''
SELECT
  id,
  full_name,
  attributes,
  enabled,
  organization_id,
  extradatauri,
  last_check,
  dialplan
FROM
  receptions
WHERE
  id = @id''';

    final Map parameters = {'id': receptionId};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No reception with id $receptionId');
      }

      return _rowToReception(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * List every reception in the database.
   */
  Future<Iterable<Model.Reception>> list() async {
    String sql = '''
SELECT
  id,
  full_name,
  attributes,
  enabled,
  organization_id,
  extradatauri,
  last_check,
  dialplan
FROM
  receptions''';

    try {
      return (await _connection.query(sql)).map(_rowToReception);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Remove a reception from the database.
   */
  Future remove(int receptionId) async {
    String sql = '''
DELETE FROM
  receptions
WHERE
  id=@id''';

    final Map parameters = {'id': receptionId};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No reception with id: $receptionId');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.Reception> update(Model.Reception reception) async {
    String sql = '''
UPDATE
  receptions
SET
  full_name = @full_name,
  attributes = @attributes,
  extradatauri = @extradatauri,
  enabled = @enabled,
  organization_id = @organization_id,
  dialplan = @dialplan
WHERE
  id=@id
RETURNING
  last_check''';

    final Map parameters = {
      'full_name': reception.fullName,
      'attributes': JSON.encode(reception.attributes),
      'extradatauri':
          reception.extraData != null ? reception.extraData.toString() : '',
      'enabled': reception.enabled,
      'id': reception.ID,
      'organization_id': reception.organizationId,
      'dialplan': reception.dialplan
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('Reception not updated');
      }

      reception.lastChecked = rows.first.last_check;
      return reception;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
