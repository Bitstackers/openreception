part of db;

Future<Map> getMessageList() {
  return _pool.connect().then((Connection conn) {
    String sql = '''
      SELECT id, message, subject, to_contact_id, taken_from, taken_by_agent, urgent, created_at, last_try, tries
      FROM message_queue
      LIMIT 100
    ''';
    //[LIMIT { number | ALL }] [OFFSET number]

    return conn.query(sql).toList().then((rows) {
      List messages = new List();
      for(var row in rows) {
        Map message =
          {'id'             : row.id,
           'message'        : row.full_name,
           'subject'        : row.uri,
           'to_contact_id'  : row.enabled,
           'taken_from'     : row.taken_from,
           'taken_by_agent' : row.taken_by_agent,
           'urgent'         : row.urgent,
           'created_at'     : row.created_at,
           'last_try'       : row.last_try,
           'tries'          :row.tries};
        messages.add(message);
      }

      return {'messages': messages};
    }).whenComplete(() => conn.close());
  });
}
