part of cdrserver.database;

Future newcdrEntry(CdrEntry entry) {

  final context = packageName + ".cdrList";

  String sql = '''
    INSERT INTO cdr_entries (uuid, inbound, reception_id, extension, duration, wait_time, started_at, json)
    VALUES (@uuid, @inbound, @reception_id, @extension, @duration, @wait_time, @started_at, @json);
  ''';

  Map parameters = {
    'uuid': entry.uuid,
    'inbound': entry.inbound,
    'reception_id': entry.reception_id,
    'extension': entry.extension,
    'duration': entry.duration,
    'wait_time': entry.waitTime,
    'started_at': entry.started_at,
    'json': JSON.encode(entry.json)
  };

  return database.execute(_pool, sql, parameters);
}
