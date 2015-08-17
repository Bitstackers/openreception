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

class Endpoint //implements Storage.Endpoint
{
  static const String className = '${libraryName}.Endpoint';

  static final Logger log = new Logger(className);

  Connection _database;

  Endpoint(this._database);

  Future<Model.MessageEndpoint> create(
      int receptionid, int contactid, Model.MessageEndpoint ep) {
    String sql = '''
INSERT INTO 
  messaging_end_points 
    (contact_id, reception_id, address, address_type, 
     confidential, enabled, priority, description)
VALUES 
  (@contactid, @receptionid,  @address, @addresstype, 
   @confidential, @enabled, @priority, @description);''';

    Map parameters = {
      'receptionid': receptionid,
      'contactid': contactid,
      'address': ep.address,
      'addresstype': ep.type,
      'confidential': ep.confidential,
      'enabled': ep.enabled,
      //'priority': ep.priority,
      'description': ep.description
    };

    return _database.execute(sql, parameters).then((_) => ep);
  }

  Future<int> remove(int receptionid, int contactid, Model.MessageEndpoint ep) {
    String sql = '''
DELETE FROM 
  messaging_end_points
WHERE 
  reception_id=@receptionid 
AND contact_id=@contactid 
AND address=@address 
AND address_type=@addresstype;''';

    Map parameters = {
      'receptionid': receptionid,
      'contactid': contactid,
      'address': ep.address,
      'addresstype': ep.type
    };

    return _database.execute(sql, parameters).then((_) => ep);
  }

  Future<Iterable<Model.MessageEndpoint>> list(int receptionid, int contactid) {
    String sql = '''
    SELECT contact_id, reception_id, address, address_type, confidential, enabled, priority, description
    FROM messaging_end_points
    WHERE reception_id=@receptionid AND contact_id=@contactid;
  ''';

    Map parameters = {'receptionid': receptionid, 'contactid': contactid};

    return _database.query(sql, parameters).then((List rows) {
      List<Model.MessageEndpoint> endpoints = [];
      for (var row in rows) {
        endpoints.add(new Model.MessageEndpoint.empty()
          ..address = row.address
          ..type = row.address_type
          ..confidential = row.confidential
          ..enabled = row.enabled
          ..description = row.description);
      }
      return endpoints;
    });
  }

  Future<Model.MessageEndpoint> update(
      int rid, int cid, Model.MessageEndpoint ep) {
    String sql = '''
    UPDATE messaging_end_points
    SET reception_id=@receptionid,
        contact_id=@contactid, 
        address=@address, 
        address_type=@addresstype, 
        confidential=@confidential, 
        enabled=@enabled, 
        priority=@priority,
        description=@description
    WHERE reception_id=@fromreceptionid AND
          contact_id=@fromcontactid AND
          address=@fromaddress AND
          address_type=@fromaddresstype;
  ''';

    Map parameters = {
      'fromreceptionid': rid,
      'fromcontactid': cid,
      'fromaddress': ep.address,
      'fromaddresstype': ep.type,
      'receptionid': rid,
      'contactid': cid,
      'address': ep.address,
      'addresstype': ep.type,
      'confidential': ep.confidential,
      'enabled': ep.enabled,
      //'priority': ep.priority,
      'description': ep.description
    };

    return _database.execute(sql, parameters).then((_) => ep);
  }
}
