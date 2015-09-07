part of cdrserver.database;

Future<List<Model.CDRCheckpoint>> getCheckpointList() {

  String sql = '''
    SELECT id, startdate, enddate, name
    FROM cdr_checkpoints
  ''';

  return connection.query(sql).then((rows) {
    _log.finest("Returned ${rows.length} checkpoints.");

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
