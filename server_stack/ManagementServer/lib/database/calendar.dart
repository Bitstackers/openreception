part of adaheads.server.database;

Future<List<model.Event>> _getReceptionContactCalendarEvents(Pool pool, int receptionId, int contactId) {
  String sql = '''
    SELECT id, start, stop, message 
    FROM contact_calendar cc
      JOIN calendar_events ce on cc.event_id = ce.id
    WHERE cc.reception_id = @reception_id AND
          cc.contact_id = @contact_id
  ''';

  Map parameters = {'reception_id': receptionId,
                    'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Event> events = new List<model.Event>();
    for(var row in rows) {
      events.add(new model.Event(row.id, row.start, row.stop, row.message));
    }
    return events;
  });
}

Future<int> _createReceptionContactCalendarEvent(Pool pool, int receptioinId, int contactId, String message, DateTime start, DateTime stop, [Map distributionList]) {
  final Completer completer = new Completer();

  pool.connect().then((Connection conn) {
    return conn.runInTransaction(() {
      //Make the Calendar Event
      String sql = '''
        INSERT INTO calendar_events (start, stop, message)
        VALUES (@start, @stop, @message)
        RETURNING id;
      ''';

      Map parameters =
        {'start'   : start,
         'stop'    : stop,
         'message' : message};

      return conn.query(sql, parameters).toList().then((rows) {
        int eventId = rows.first.id;
        //Linked the event together with the contact.

        String sql = '''
        INSERT INTO contact_calendar (reception_id, contact_id, distribution_list, event_id)
        VALUES (@reception_id, @contact_id, @distribution_list, @event_id);
      ''';

        Map parameters =
          {'reception_id'      : receptioinId,
           'contact_id'        : contactId,
           'distribution_list' : distributionList == null ? null : JSON.encode(distributionList),
           'event_id'          : eventId};

        return conn.execute(sql, parameters).then((_) {
          completer.complete(eventId);
        });
      });
    });
  }).catchError((error, stack) {
    completer.completeError(error, stack);
  });

  return completer.future;
}

Future<int> _updateCalendarEvent(Pool pool, int eventId, String message, DateTime start, DateTime stop, [Map distributionList]) {
  String sql = '''
    UPDATE calendar_events
    SET start=@start, 
        stop=@stop, 
        message=@message
    WHERE id=@id;
  ''';

  Map parameters =
    {'start'   : start,
     'stop'    : stop,
     'message' : message,
     'id'      : eventId};

  return execute(pool, sql, parameters);
}

Future<int> _deleteCalendarEvent(Pool pool, int eventId) {
  String sql = '''
      DELETE FROM calendar_events
      WHERE id=@id;
    ''';

  Map parameters = {'id': eventId};
  return execute(pool, sql, parameters);
}
