/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.management_server.database;

Future<Dialplan> _getDialplan(ORDatabase.Connection connection, int receptionId) {
  String sql = '''
    SELECT id, dialplan, reception_telephonenumber, dialplan_compiled
    FROM receptions
    WHERE id = @id
  ''';

  Map parameters = {'id': receptionId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      Map dialplanMap = row._dialplan != null ? row._dialplan : {};
      Dialplan dialplan = new Dialplan.fromJson(dialplanMap);

      //In case the json is empty.
      if(dialplan == null) {
        dialplan = new Dialplan();
      }

      dialplan
        ..receptionId = row.id
        ..entryNumber = row.reception_telephonenumber
        ..isCompiled = row.dialplan_compiled;

      return dialplan;
    }
  });
}

Future _updateDialplan(ORDatabase.Connection connection, int receptionId, Map dialplan) {
  String sql = '''
    UPDATE receptions
    SET dialplan=@dialplan, dialplan_compiled=false
    WHERE id=@id;
  ''';

  Map parameters =
    {'dialplan': dialplan,
     'id'      : receptionId};

  return connection.execute(sql, parameters);
}

Future _markDialplanAsCompiled(ORDatabase.Connection connection, int receptionId) {
  String sql = '''
    UPDATE receptions
    SET dialplan_compiled=true
    WHERE id=@id;
  ''';

  Map parameters = {'id': receptionId};

  return connection.execute(sql, parameters);
}

Future<IvrList> _getIvr(ORDatabase.Connection connection, int receptionId) {
  String sql = '''
    SELECT id, ivr
    FROM receptions
    WHERE id = @id
  ''';

  Map parameters = {'id': receptionId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      Map ivrMap = row.ivr != null ? row.ivr : {};
      IvrList ivrList = new IvrList.fromJson(ivrMap);

      //In case the json is empty.
      if(IvrList == null) {
        ivrList = new IvrList();
      }

      return ivrList;
    }
  });
}

Future _updateIvr(ORDatabase.Connection connection, int receptionId, Map ivr) {
  String sql = '''
    UPDATE receptions
    SET ivr=@ivr
    WHERE id=@id;
  ''';

  Map parameters =
    {'ivr': ivr,
     'id' : receptionId};

  return connection.execute(sql, parameters);
}

Future<List<model.Playlist>> _getPlaylistList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, content
    FROM playlists
  ''';

  return connection.query(sql).then((List rows) {
    List<model.Playlist> receptions = new List<model.Playlist>();
    for(var row in rows) {
      Map content = row.content;
      receptions.add(new model.Playlist.fromDb(row.id, content));
    }
    return receptions;
  });
}

Future<int> _createPlaylist(
    ORDatabase.Connection connection,
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
    {'content' : content};

  return connection.query(sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deletePlaylist(ORDatabase.Connection connection, int playlistId) {
  String sql = '''
      DELETE FROM playlists
      WHERE id=@id;
    ''';

  Map parameters = {'id': playlistId};
  return connection.execute(sql, parameters);
}

Future<model.Playlist> _getPlaylist(ORDatabase.Connection connection, int playlistId) {
  String sql = '''
    SELECT id, content
    FROM playlists
    WHERE id = @id
  ''';

  Map parameters = {'id': playlistId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      return new model.Playlist.fromDb(row.id, row.content);
    }
  });
}

Future<int> _updatePlaylist(
    ORDatabase.Connection connection,
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
     'content' : content};

  return connection.execute(sql, parameters);
}

Future<List<model.DialplanTemplate>> _getDialplanTemplates(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, template
    FROM dialplan_templates
  ''';

  return connection.query (sql).then((List rows) {
    List<model.DialplanTemplate> templates = new List<model.DialplanTemplate>();
    for(var row in rows) {
      Map content = row.template;
      templates.add(new model.DialplanTemplate.fromDb(row.id, content));
    }
    return templates;
  });
}
