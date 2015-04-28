part of cdrserver.database;

Future createCheckpoint(Checkpoint checkpoint) {

  String sql = '''
    INSERT INTO cdr_checkpoints (startDate, endDate, name)
    VALUES (@startdate, @enddate, @name);
  ''';

  Map parameters = {
    'startdate': checkpoint.start,
    'enddate': checkpoint.end,
    'name': checkpoint.name
  };

  return connection.execute(sql, parameters);
}
