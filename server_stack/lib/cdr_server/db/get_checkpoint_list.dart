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

Future<List<Model.CDRCheckpoint>> getCheckpointList() {

  String sql = '''
    SELECT id, startdate, enddate, name
    FROM cdr_checkpoints
  ''';

  return connection.query(sql).then((rows) {
    _log.finest("Returned ${rows.length} checkpoints.");

    List<Model.CDRCheckpoint> checkpointList = new List<Model.CDRCheckpoint>();

    for(var row in rows) {
      checkpointList.add(
          new Model.CDRCheckpoint.empty()
            ..id = row.id
            ..start = row.startdate
            ..end = row.enddate
            ..name = row.name);
    }

    return checkpointList;
  });
}
