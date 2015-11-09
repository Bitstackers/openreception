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

class Cdr {
  ///Logger
  final Logger _log = new Logger('${libraryName}.Cdr');

  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor.
   */
  Cdr(this._connection);

  /**
   *
   */
  Future<Iterable<Model.CDREntry>> list(
      bool inbound, DateTime start, DateTime end) {
    String sql = '''
  SELECT 
            (org.id)        AS org_id,
            (org.full_name) AS org_name,
            (org.billing_type) AS billing_type,
            (org.flag)      AS flag,
      COUNT (cdr.uuid)      AS call_count, 
      SUM   (cdr.duration)  AS total_duration,
      SUM   (wait_time)     AS total_wait,
      ceiling(AVG   (cdr.duration))  AS avg_duration
      
  FROM 
       cdr_entries   cdr
  JOIN receptions    rcp ON cdr.reception_id    = rcp.id
  JOIN organizations org ON rcp.organization_id = org.id

  WHERE cdr.inbound   = @inbound AND
        cdr.started_at >= @start   AND
        cdr.started_at <  @end   

  GROUP by
     org.id,
     org.full_name;
  ''';

    Map parameters = {'inbound': inbound, 'start': start, 'end': end};

    return _connection.query(sql, parameters).then((rows) {
      _log.finest("Returned ${rows.length} reception cdr stats.");

      List cdr = new List();

      for (var row in rows) {
        cdr.add(new Model.CDREntry.empty()
          ..orgId = row.org_id
          ..orgName = row.org_name
          ..billingType = row.billing_type
          ..flag = row.flag
          ..callCount = row.call_count
          ..duration = row.total_duration
          ..totalWait = row.total_wait
          ..avgDuration = double.parse(row.avg_duration));
      }

      return cdr;
    });
  }

  /**
   *
   */
  Future createCheckpoint(Model.CDRCheckpoint checkpoint) {
    String sql = '''
    INSERT INTO cdr_checkpoints 
      (startDate, endDate, name)
    VALUES 
      (@startdate, @enddate, @name)''';

    Map parameters = {
      'startdate': checkpoint.start,
      'enddate': checkpoint.end,
      'name': checkpoint.name
    };

    return _connection.execute(sql, parameters);
  }

  /**
   *
   */
  Future<List<Model.CDRCheckpoint>> checkpointList() {
    String sql = '''
    SELECT 
      id, startdate, enddate, name
    FROM 
      cdr_checkpoints''';

    return _connection.query(sql).then((rows) {
      _log.finest("Returned ${rows.length} checkpoints.");

      List<Model.CDRCheckpoint> checkpointList =
          new List<Model.CDRCheckpoint>();

      for (var row in rows) {
        checkpointList.add(new Model.CDRCheckpoint.empty()
          ..id = row.id
          ..start = row.startdate
          ..end = row.enddate
          ..name = row.name);
      }

      return checkpointList;
    });
  }

  /**
   *
   */
  Future get(String uuid) {
    String sql = '''
  SELECT 
            (org.id)        AS org_id,
            (org.full_name) AS org_name,
            (org.billing_type) AS billing_type,
            (org.flag)      AS flag,
      COUNT (cdr.uuid)      AS call_count, 
      SUM   (cdr.duration)  AS total_duration,
      SUM   (wait_time)     AS total_wait,
      ceiling(AVG   (cdr.duration))  AS avg_duration
      
  FROM 
       cdr_entries   cdr
  JOIN receptions    rcp ON cdr.reception_id    = rcp.id
  JOIN organizations org ON rcp.organization_id = org.id

  WHERE cdr.uuid = @uuid   

  GROUP by
     org.id,
     org.full_name;
  ''';

    Map parameters = {'uuid': uuid};

    return _connection.query(sql, parameters).then((rows) => rows.length == 1
        ? (new Model.CDREntry.empty()
          ..orgId = rows.first.org_id
          ..orgName = rows.first.org_name
          ..billingType = rows.first.billing_type
          ..flag = rows.first.flag
          ..callCount = rows.first.call_count
          ..duration = rows.first.total_duration
          ..totalWait = rows.first.total_wait
          ..avgDuration = double.parse(rows.first.avg_duration))
        : throw new Storage.NotFound());
  }

  /**
   *
   */
  Future create(Model.FreeSWITCHCDREntry entry) {
    String sql = '''
    INSERT INTO cdr_entries 
      (uuid, inbound, reception_id, extension, 
       duration, wait_time, started_at, json)
    VALUES 
      (@uuid, @inbound, @reception_id, @extension, 
       @duration, @wait_time, @started_at, @json)''';

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

    return _connection.execute(sql, parameters);
  }
}
