part of cdrserver.database;

Future<List> cdrList(bool inbound, DateTime start, DateTime end) {

  final context = packageName + ".cdrList";

  String sql = '''
  SELECT 
            (org.id)        AS org_id,
            (org.full_name) AS org_name,
            (org.bill_type) AS bill_type,
            (org.flag)      AS flag,
      COUNT (cdr.uuid)      AS call_count, 
      SUM   (cdr.duration)  AS total_duration,
      SUM   (wait_time)     AS total_wait
      
  FROM 
       cdr_entries   cdr
  JOIN receptions    rcp ON cdr.reception_id    = rcp.id
  JOIN organizations org ON rcp.organization_id = org.id

  WHERE cdr.inbound   = @inbound AND
        cdr.ended_at >= @start   AND
        cdr.ended_at <  @end   

  GROUP by
     org.id,
     org.full_name;
  ''';

  Map parameters = {'inbound' : inbound,
                    'start'   : start,
                    'end'     : end};



  return database.query(_pool, sql, parameters).then((rows) {
    logger.debugContext("Returned ${rows.length} queued messages.", context);

    List cdr = new List();

    for(var row in rows) {

      cdr.add({'org_id'     : row.org_id,
                 'org_name'   : row.org_name,
                 'bill_type'  : row.bill_type,
                 'flag'       : row.flag,
                 'call_count' : row.call_count,
                 'duration'   : row.total_duration,
                 'total_wait' : row.total_wait});
    }

    return cdr;
  });
}
