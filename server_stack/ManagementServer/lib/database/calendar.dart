part of adaheads.server.database;

Future<List<model.Event>> _getReceptionContactCalendarEvents(ORDatabase.Connection connection, int receptionId, int contactId) {
  String sql = '''
    SELECT id, start, stop, message 
    FROM contact_calendar cc
      JOIN calendar_events ce on cc.event_id = ce.id
    WHERE cc.reception_id = @reception_id AND
          cc.contact_id = @contact_id
  ''';

  Map parameters = {'reception_id': receptionId,
                    'contact_id': contactId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.Event> events = new List<model.Event>();
    for(var row in rows) {
      events.add(new model.Event(row.id, row.start, row.stop, row.message));
    }
    return events;
  });
}

Future<int> _createReceptionContactCalendarEvent(ORDatabase.Connection connection, int receptioinId, int contactId, String message, DateTime start, DateTime stop, [Map distributionList]) {
  return connection.runInTransaction(() {
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

      return connection.query(sql, parameters).then((rows) {
        int eventId = rows.first.id;
        //Linked the event together with the contact.

        String sql = '''
        INSERT INTO contact_calendar (reception_id, contact_id, distribution_list, event_id)
        VALUES (@reception_id, @contact_id, @distribution_list, @event_id);
      ''';

        Map parameters =
          {'reception_id'      : receptioinId,
           'contact_id'        : contactId,
           'distribution_list' : distributionList == null ? null : distributionList,
           'event_id'          : eventId};

        return connection.execute(sql, parameters).then((_) {
          return eventId;
        });
      });
    });
}

Future<int> _updateCalendarEvent(ORDatabase.Connection connection, int eventId, String message, DateTime start, DateTime stop, [Map distributionList]) {
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

  return connection.execute(sql, parameters);
}

Future<int> _deleteCalendarEvent(ORDatabase.Connection connection, int eventId) {
  String sql = '''
      DELETE FROM calendar_events
      WHERE id=@id;
    ''';

  Map parameters = {'id': eventId};
  return connection.execute(sql, parameters);
}
