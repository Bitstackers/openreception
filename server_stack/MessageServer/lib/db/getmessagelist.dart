part of db;

Future<Map> getMessageList() {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
      SELECT id, message, subject, to_contact_id, taken_from, taken_by_agent, urgent, created_at, last_try, tries
      FROM message_queue
    ''';

    conn.query(sql).toList().then((rows) {
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

      Map data = {'messages': messages};

      completer.complete(data);
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());
  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
