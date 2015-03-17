library adaheads.server.view.playlist;

import 'dart:convert';

import '../model.dart';

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
