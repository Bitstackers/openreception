part of cdrserver.database;

Future<List<Checkpoint>> getCheckpointList() {
  final context = libraryName + ".checkpointList";

  String sql = '''
    SELECT id, startdate, enddate, name
    FROM cdr_checkpoints
  ''';

  return connection.query(sql).then((rows) {
    logger.debugContext("Returned ${rows.length} checkpoints.", context);

    List<Checkpoint> checkpointList = new List<Checkpoint>();

    for(var row in rows) {
      checkpointList.add(
          new Checkpoint()
            ..id = row.id
            ..start = row.startdate
            ..end = row.enddate
            ..name = row.name);
    }

    return checkpointList;
  });
}
