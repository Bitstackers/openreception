part of messagedispatcher.database;

Future<List> messageQueueList() {
  
  final context = packageName + ".messageQueueList";
  
  int limit = 100;
  String sql = '''
   SELECT 
       mq.id,
       mq.message_id,
       msg.context_contact_name,
       mq.last_try,
       mq.tries

   FROM message_queue          mq
   JOIN messages msg ON mq.message_id = msg.id

   ORDER BY
       mq.last_try DESC,
       msg.created_at DESC
   LIMIT ${limit} 
  ''';

  return database.query(_pool, sql).then((rows) {
    logger.debugContext("Returned ${rows.length} queued messages (limit $limit).", context);

    List queue = new List();
    
    for(var row in rows) {
     
      queue.add({'queue_id'       : row.id,
                 'message_id'     : row.message_id,
                 'context_contact_name' : row.context_contact_name,
                 'last_try'       : row.last_try,
                 'tries'          : row.tries});
    }

    return queue;
  });
}
