part of cdrserver.database;

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
