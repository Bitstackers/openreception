part of cdrserver.database;

Future<List<Model.CDRCheckpoint>> getCheckpointList() {
  final context = libraryName + ".checkpointList";

  String sql = '''
    SELECT id, startdate, enddate, name
    FROM cdr_checkpoints
  ''';

  return connection.query(sql).then((rows) {
    logger.debugContext("Returned ${rows.length} checkpoints.", context);

    List<Model.CDRCheckpoint> checkpointList = new List<Model.CDRCheckpoint>();

    for(var row in rows) {
      checkpointList.add(
          new Model.CDRCheckpoint.empty()
            ..id = row.id
            ..start = row.startdate
            ..end = row.enddate
            ..name = row.name);
    }

    return checkpointList;
  });
}
