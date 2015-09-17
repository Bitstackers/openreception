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

library openreception.management_server.view.playlist;

import 'dart:convert';

import 'package:openreception_framework/model.dart';

String playlistListAsJson(List<Playlist> playlists) =>
    JSON.encode({'playlist':_listPlaylistAsJsonList(playlists)});

String playlistAsJson(Playlist playlist) => JSON.encode(_playlistAsJsonMap(playlist));

String playlistIdAsJson(int id) => JSON.encode({'id': id});

Map _playlistAsJsonMap(Playlist playlist) => playlist == null ? {} :
    {'id':        playlist.id,
     'name':      playlist.name,
     'path':      playlist.path,
     'shuffle':   playlist.shuffle,
     'channels':  playlist.channels,
     'interval':  playlist.interval,
     'chimelist': playlist.chimelist,
     'chimefreq': playlist.chimefreq,
     'chimemax':  playlist.chimemax};

List _listPlaylistAsJsonList(List<Playlist> playlists) =>
    playlists.map(_playlistAsJsonMap).toList();
