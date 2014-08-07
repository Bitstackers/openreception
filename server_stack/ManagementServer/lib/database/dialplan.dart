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

Future<IvrList> _getIvr(Pool pool, int receptionId) {
  String sql = '''
    SELECT id, ivr
    FROM receptions
    WHERE id = @id
  ''';

  Map parameters = {'id': receptionId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      Map ivrMap = JSON.decode(row.ivr != null ? row.ivr : '{}');
      IvrList ivrList = new IvrList.fromJson(ivrMap);

      //In case the json is empty.
      if(IvrList == null) {
        ivrList = new IvrList();
      }

      return ivrList;
    }
  });
}

Future _updateIvr(Pool pool, int receptionId, Map ivr) {
  String sql = '''
    UPDATE receptions
    SET ivr=@ivr
    WHERE id=@id;
  ''';

  Map parameters =
    {'ivr': JSON.encode(ivr),
     'id' : receptionId};

  return execute(pool, sql, parameters);
}

Future<List<model.Playlist>> _getPlaylistList(Pool pool) {
  String sql = '''
    SELECT id, content
    FROM playlists
  ''';

  return query(pool, sql).then((List<Row> rows) {
    List<model.Playlist> receptions = new List<model.Playlist>();
    for(Row row in rows) {
      Map content = JSON.decode(row.content);
      receptions.add(new model.Playlist.fromDb(row.id, content));
    }
    return receptions;
  });
}

Future<int> _createPlaylist(
    Pool         pool,
    String       name,
    String       path,
    bool         shuffle,
    int          channels,
    int          interval,
    List<String> chimelist,
    int          chimefreq,
    int          chimemax) {

  String sql = '''
    INSERT INTO playlists (content)
    VALUES (@content)
    RETURNING id;
  ''';

  Map content =
    {'name': name,
     'path': path,
     'shuffle': shuffle,
     'channels': channels,
     'interval': interval,
     'chimelist': chimelist,
     'chimefreq': chimefreq,
     'chimemax': chimemax};

  Map parameters =
    {'content' : JSON.encode(content)};

  return query(pool, sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deletePlaylist(Pool pool, int playlistId) {
  String sql = '''
      DELETE FROM playlists
      WHERE id=@id;
    ''';

  Map parameters = {'id': playlistId};
  return execute(pool, sql, parameters);
}

Future<model.Playlist> _getPlaylist(Pool pool, int playlistId) {
  String sql = '''
    SELECT id, content
    FROM playlists
    WHERE id = @id
  ''';

  Map parameters = {'id': playlistId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new model.Playlist.fromDb(row.id, JSON.decode(row.content));
    }
  });
}

Future<int> _updatePlaylist(
    Pool         pool,
    int          id,
    String       name,
    String       path,
    bool         shuffle,
    int          channels,
    int          interval,
    List<String> chimelist,
    int          chimefreq,
    int          chimemax) {

  String sql = '''
    UPDATE playlists
    SET content=@content
    WHERE id=@id;
  ''';

  Map content =
    {'name': name,
     'path': path,
     'shuffle': shuffle,
     'channels': channels,
     'interval': interval,
     'chimelist': chimelist,
     'chimefreq': chimefreq,
     'chimemax': chimemax};

  Map parameters =
    {'id'      : id,
     'content' : JSON.encode(content)};

  return execute(pool, sql, parameters);
}

Future<List<model.DialplanTemplate>> _getDialplanTemplates(Pool pool) {
  String sql = '''
    SELECT id, template
    FROM dialplan_templates
  ''';

  return query(pool, sql).then((List<Row> rows) {
    List<model.DialplanTemplate> templates = new List<model.DialplanTemplate>();
    for(Row row in rows) {
      Map content = JSON.decode(row.template);
      templates.add(new model.DialplanTemplate.fromDb(row.id, content));
    }
    return templates;
  });
}
