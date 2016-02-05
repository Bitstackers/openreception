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

class Endpoint implements Storage.Endpoint {
  Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  Endpoint(this._connection);

  /**
   *
   */
  Future<Model.MessageEndpoint> create(
      int receptionid, int contactid, Model.MessageEndpoint ep) async {
    String sql = '''
INSERT INTO
  messaging_end_points
    (contact_id, reception_id, address, address_type,
     confidential, enabled, priority, description)
VALUES
  (@contactid, @receptionid,  @address, @addresstype,
   @confidential, @enabled, @priority, @description)
RETURNING id''';

    final Map parameters = {
      'receptionid': receptionid,
      'contactid': contactid,
      'address': ep.address,
      'addresstype': ep.type,
      'confidential': ep.confidential,
      'enabled': ep.enabled,
      'priority': ep.priority,
      'description': ep.description
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('MessageEndpoint not created');
      }

      ep.id = rows.first.id;
      return ep;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<int> remove(int endpointId) {
    String sql = '''
DELETE FROM
  messaging_end_points
WHERE id = @endpointId''';

    Map parameters = {'endpointId': endpointId};

    return _connection.execute(sql, parameters);
  }

  /**
   *
   */
  Future<Iterable<Model.MessageEndpoint>> list(
      int receptionId, int contactId) async {
    String sql = '''
SELECT
  id,
  contact_id,
  reception_id,
  address, address_type,
  confidential,
  enabled,
  priority,
  description
FROM
  messaging_end_points
WHERE
  reception_id = @receptionid
AND
  contact_id = @contactid''';

    Map parameters = {'receptionid': receptionId, 'contactid': contactId};

    try {
      final Iterable<PG.Row> rows = await _connection.query(sql, parameters);

      return rows.map(_rowToMessageEndpoint);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.MessageEndpoint> update(Model.MessageEndpoint ep) async {
    String sql = '''
UPDATE
  messaging_end_points
SET
  address=@address,
  address_type=@addresstype,
  confidential=@confidential,
  enabled=@enabled,
  priority=@priority,
  description=@description
WHERE
  id = @ep_id''';

    Map parameters = {
      'ep_id': ep.id,
      'fromaddress': ep.address,
      'fromaddresstype': ep.type,
      'address': ep.address,
      'addresstype': ep.type,
      'confidential': ep.confidential,
      'enabled': ep.enabled,
      'priority': ep.priority,
      'description': ep.description
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('User not updated');
      }

      return ep;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
