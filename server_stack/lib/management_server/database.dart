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

library openreception.management_server.database;

import 'dart:async';

import 'package:openreception_framework/database.dart' as ORDatabase;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import 'package:openreception_framework/model.dart' as model;

import '../configuration.dart';

part 'database/dialplan.dart';


const String _libraryName = 'openreception.management_server.database';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config);
  return db.start().then((_) => db);
}

class Database {
  final Configuration _config;
  ORDatabase.Connection _connection;

  Database(this._config);

  Future start() {
    return ORDatabase.Connection.connect (_config.database.dsn)
      .then((ORDatabase.Connection newConnection) =>
          _connection = newConnection);
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
