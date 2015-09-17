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

part of openreception.cdr_server.database;

//TODO "owner" and "contact_id" is not part of the database tuppel.
Future newcdrEntry(Model.FreeSWITCHCDREntry entry) {

  String sql = '''
    INSERT INTO cdr_entries (uuid, inbound, reception_id, extension, duration, wait_time, started_at, json)
    VALUES (@uuid, @inbound, @reception_id, @extension, @duration, @wait_time, @started_at, @json);
  ''';

  Map parameters = {
    'uuid': entry.uuid,
    'inbound': entry.inbound,
    'reception_id': entry.receptionId,
    'extension': entry.extension,
    'duration': entry.duration,
    'wait_time': entry.waitTime,
    'started_at': entry.startedAt,
    'json': entry.json
  };

  return connection.execute(sql, parameters);
}
