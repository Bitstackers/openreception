part of cdrserver.database;

Future<List> cdrList(bool inbound, DateTime start, DateTime end) {

  final context = libraryName + ".cdrList";

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

  Map parameters = {'inbound' : inbound,
                    'start'   : start,
                    'end'     : end};

  return connection.query(sql, parameters).then((rows) {
    logger.debugContext("Returned ${rows.length} reception cdr stats.", context);

    List cdr = new List();

    for(var row in rows) {

      cdr.add({'org_id'       : row.org_id,
               'org_name'     : row.org_name,
               'billing_type' : row.billing_type,
               'flag'         : row.flag,
               'call_count'   : row.call_count,
               'duration'     : row.total_duration,
               'total_wait'   : row.total_wait,
               'avg_duration' : double.parse(row.avg_duration)});
    }

    return cdr;
  });
}
