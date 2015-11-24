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
  static const String className = '${libraryName}.Organization';

  static final Logger log = new Logger(className);

  Connection _connection = null;

  /**
   * Constructor.
   */
  Reception(Connection this._connection);

  Future<Model.Reception> create(Model.Reception reception) {
    String sql = '''
    INSERT INTO 
      receptions 
        (organization_id, full_name, attributes, extradatauri, 
         enabled, reception_telephonenumber, dialplanId)
    VALUES 
        (@organization_id, @full_name, @attributes, @extradatauri, 
         @enabled, @reception_telephonenumber, dialplanId)
    RETURNING 
      id, last_check;
  ''';

    Map parameters = {
      'organization_id': reception.organizationId,
      'full_name': reception.fullName,
      'attributes': JSON.encode(reception.attributes),
      'extradatauri': reception.extraData.toString(),
      'enabled': reception.enabled,
      'reception_telephonenumber': reception.extension,
      'dialplanId' : reception.dialplanId
    };

    return _connection.query(sql, parameters).then(
        (Iterable rows) => rows.length == 1
            ? (reception
      ..ID = rows.first.id
      ..lastChecked = rows.first.last_check)
        : new Future.error(new Storage.ServerError())
            .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');

      return new Future.error(error, stackTrace);
    }));
  }

  /**
   * Retrieve a specific reception from the database identified
   * by its extension.
   */
  Future<Model.Reception> getByExtension (String extension) {
    String sql = '''
      SELECT 
        id, full_name, attributes, enabled, organization_id,
        extradatauri, reception_telephonenumber, last_check, dialplanId
      FROM receptions
      WHERE reception_telephonenumber = @exten 
    ''';

    Map parameters = {'exten': extension};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? new Future.error(
                new Storage.NotFound('No reception with extension $extension'))
            : _rowToReception(rows.first))
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('sql:$sql :: parameters:$parameters');
      }

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrieve the extension of a specific reception from the database
   * identified its ID.
   */
  Future<String> extensionOf (int receptionId) {
    String sql = '''
      SELECT reception_telephonenumber
      FROM receptions
      WHERE id = @id
    ''';

    Map parameters = {'id': receptionId};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? new Future.error(
                new Storage.NotFound('No reception with id $receptionId'))
            : rows.first.reception_telephonenumber)
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('sql:$sql :: parameters:$parameters');
      }

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrieve a specific reception from the database.
   */
  Future<Model.Reception> get(int id) {
    String sql = '''
      SELECT 
        id, full_name, attributes, enabled, organization_id,
        extradatauri, reception_telephonenumber, last_check, dialplanId
      FROM receptions
      WHERE id = @id 
    ''';

    Map parameters = {'id': id};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? new Future.error(new Storage.NotFound('No reception with ID $id'))
            : _rowToReception(rows.first))
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('sql:$sql :: parameters:$parameters');
      }

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * List every reception in the database.
   */
  Future<Iterable<Model.Reception>> list() {
    String sql = '''
      SELECT 
        id, full_name, attributes, enabled, organization_id,
        extradatauri, reception_telephonenumber, last_check, dialplanId
      FROM receptions
    ''';

    return _connection
        .query(sql)
        .then((rows) => (rows as Iterable).map(_rowToReception))
        .catchError((error, stackTrace) {
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Remove a reception from the database.
   */
  Future remove(int receptionID) {
    String sql = '''
      DELETE FROM receptions
      WHERE id=@id;
    ''';

    Map parameters = {'id': receptionID};
    return _connection     .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected != 1
            ? new Future.error(new Storage.NotFound('rid:$receptionID'))
            : null)
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('sql:$sql :: parameters:$parameters');
      }

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * FIXME: This method uses a local timestamp rather than echo the real
   *   timestamp from the database.
   */
  Future<Model.Reception> update(Model.Reception reception) {
    String sql = '''
    UPDATE receptions
    SET full_name=@full_name, 
        attributes=@attributes, 
        extradatauri=@extradatauri, 
        enabled=@enabled, 
        reception_telephonenumber=@reception_telephonenumber,
        organization_id=@organization_id,
        dialplanId=@dialplanId
    WHERE id=@id;
  ''';

    Map parameters = {
      'full_name': reception.fullName,
      'attributes': JSON.encode(reception.attributes),
      'extradatauri': reception.extraData.toString(),
      'enabled': reception.enabled,
      'id': reception.ID,
      'organization_id': reception.organizationId,
      'reception_telephonenumber': reception.extension,
      'dialplanId' : reception.dialplanId
    };

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected != 1
            ? new Future.error(new Storage.NotFound('rid:$reception.ID'))
            : (reception..lastChecked = new DateTime.now()))
        .catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new Future.error(error);
      }

      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(new Storage.ServerError(error.toString()));
    });
  }
}
