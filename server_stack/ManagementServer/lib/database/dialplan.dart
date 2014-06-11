part of adaheads.server.database;

Future<Dialplan> _getDialplan(Pool pool, int receptionId) {
  String sql = '''
    SELECT id, dialplan, reception_telephonenumber
    FROM receptions
    WHERE id = @id
  ''';

  Map parameters = {'id': receptionId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      Map dialplanMap = JSON.decode(row.dialplan != null ? row.dialplan : '{}');
      Dialplan dialplan = new Dialplan.fromJson(dialplanMap);

      //In case the json is empty.
      if(dialplan == null) {
        dialplan = new Dialplan();
      }

      dialplan
        ..receptionId = row.id
        ..entryNumber = row.reception_telephonenumber;
      return dialplan;
    }
  });
}

Future _updateDialplan(Pool pool, int receptionId, Map dialplan) {
  String sql = '''
    UPDATE receptions
    SET dialplan=@dialplan
    WHERE id=@id;
  ''';

  Map parameters =
    {'dialplan': JSON.encode(dialplan),
     'id'      : receptionId};

  return execute(pool, sql, parameters);
}

Future<List<model.Audiofile>> _getAudiofileList(Pool pool) {
  String sql = '''
    SELECT filepath, shortname
    FROM audiofiles;
  ''';

  return query(pool, sql).then((rows) {
    List<model.Audiofile> audiofiles = new List<model.Audiofile>();
    for(var row in rows) {
      audiofiles.add(new model.Audiofile(row.filepath, row.shortname));
    }
    return audiofiles;
  });
}
