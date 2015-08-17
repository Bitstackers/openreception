library adaheads.server.database;

import 'dart:async';
import 'dart:convert';

import 'package:openreception_framework/database.dart' as ORDatabase;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import 'package:openreception_framework/model.dart' as model;

import 'configuration.dart';

part 'database/calendar.dart';
part 'database/contact.dart';
part 'database/dialplan.dart';
part 'database/distribution_list.dart';
part 'database/endpoint.dart';
part 'database/organization.dart';
part 'database/reception.dart';
part 'database/reception_contact.dart';
part 'database/user.dart';

ORDatabase.Connection _connection;
const String libraryName = 'adaheads.server.database';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

class Database {
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;

  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});

  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';

    return ORDatabase.Connection.connect (connectString)
        .then((ORDatabase.Connection newConnection) => _connection = newConnection);
  }

  /* ***********************************************
     ****************** Dialplan *******************
   */

  Future<Dialplan> getDialplan(int receptionId) =>
      _getDialplan(_connection, receptionId);

  Future updateDialplan(int receptionId, Map dialplan) =>
      _updateDialplan(_connection, receptionId, dialplan);

  Future markDialplanAsCompiled(int receptionId) =>
      _markDialplanAsCompiled(_connection, receptionId);

  Future<IvrList> getIvr(int receptionId) =>
      _getIvr(_connection, receptionId);

  Future updateIvr(int receptionId, Map ivr) =>
      _updateIvr(_connection, receptionId, ivr);

  Future<List<model.DialplanTemplate>> getDialplanTemplates() =>
      _getDialplanTemplates(_connection);

  /* ***********************************************
     ****************** Playlist *******************
   */

  Future<int> createPlaylist(
      String       name,
      String       path,
      bool         shuffle,
      int          channels,
      int          interval,
      List<String> chimelist,
      int          chimefreq,
      int          chimemax) =>
      _createPlaylist(_connection,
                      name,
                      path,
                      shuffle,
                      channels,
                      interval,
                      chimelist,
                      chimefreq,
                      chimemax);


  Future<int> deletePlaylist(int playlistId) => _deletePlaylist(_connection, playlistId);

  Future<model.Playlist> getPlaylist(int playlistId) => _getPlaylist(_connection, playlistId);

  Future<List<model.Playlist>> getPlaylistList() =>
      _getPlaylistList(_connection);

  Future<int> updatePlaylist(
      int          id,
      String       name,
      String       path,
      bool         shuffle,
      int          channels,
      int          interval,
      List<String> chimelist,
      int          chimefreq,
      int          chimemax) =>
      _updatePlaylist(
          _connection,
          id,
          name,
          path,
          shuffle,
          channels,
          interval,
          chimelist,
          chimefreq,
          chimemax);

}
