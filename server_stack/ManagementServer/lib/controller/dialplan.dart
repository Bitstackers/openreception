library dialplanController;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import '../configuration.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/audiofile.dart';
import '../view/dialplan.dart';
import '../view/playlist.dart';
import '../view/ivr.dart';
import '../service/audiofiles.dart' as service;

class DialplanController {
  Database db;
  Configuration config;

  DialplanController(Database this.db, Configuration this.config);

  void getAudiofileList(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    String token = request.uri.queryParameters['token'];

    service.getAudioFileList(config.dialplanCompilerServer, receptionId, token).then((http.Response response) {
      if(response.statusCode == 200) {
        List<String> files = JSON.decode(response.body)['files'];
        List<Audiofile> audioFiles = files.map((file) => new Audiofile(file, file.split('/').last)).toList();
        return writeAndCloseJson(request, listAudiofileAsJson(audioFiles));
      } else {
        request.response.statusCode = response.statusCode;
        return writeAndCloseJson(request, response.body);
      }
    }).catchError((error) {
      logger.error('DialplanController.getAudiofileList: ${error}');
      Internal_Error(request, error);
    });
  }

  void getDialplan(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    db.getDialplan(receptionId)
      .then((Dialplan dialplan) => writeAndCloseJson(request, dialplanAsJson(dialplan)))
      .catchError((error) {
        logger.error('getDialplan url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
    });
  }

  void updateDialplan(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateDialplan(receptionId, data))
      .then((_) => writeAndCloseJson(request, JSON.encode({})))
      .catchError((error, stack) {
        logger.error('updateDialplan url: "${request.uri}" gave error "${error}" ${stack}');
        Internal_Error(request);
    });
  }

  void getIvr(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    db.getIvr(receptionId)
      .then((IvrList ivrList) => writeAndCloseJson(request, ivrListAsJson(ivrList)))
      .catchError((error) {
        logger.error('getIvr url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
    });
  }

  void updateIvr(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateIvr(receptionId, data))
      .then((_) => writeAndCloseJson(request, JSON.encode({})))
      .catchError((error, stack) {
        logger.error('updateIvr url: "${request.uri}" gave error "${error}" ${stack}');
        Internal_Error(request);
    });
  }

  void getPlaylists(HttpRequest request) {
    db.getPlaylistList()
      .then((List<Playlist> playlists) => writeAndCloseJson(request, playlistListAsJson(playlists)))
      .catchError((error) {
        logger.error('getPlaylists url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
    });
  }

  void createPlaylist(HttpRequest request) {
    extractContent(request)
      .then(JSON.decode)
      .then((Map data) {
        return db.createPlaylist(
          data['name'],
          data['path'],
          data['shuffle'],
          data['channels'],
          data['interval'],
          data['chimelist'],
          data['chimefreq'],
          data['chimemax']);})
      .then((int id) => writeAndCloseJson(request, playlistIdAsJson(id)))
      .catchError((error, stack) {
        logger.error('create playlist failed: $error ${stack}');
        Internal_Error(request);
      });
  }

  void deletePlaylist(HttpRequest request) {
    int playlistId = intPathParameter(request.uri, 'playlist');

    db.deletePlaylist(playlistId)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('deletePlaylist url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getPlaylist(HttpRequest request) {
    int playlistId = intPathParameter(request.uri, 'playlist');

    db.getPlaylist(playlistId).then((Playlist playlist) {
      if(playlist == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, playlistAsJson(playlist));
      }
    }).catchError((error, stack) {
      logger.error('get playlist Error: "$error" "${stack}"');
      Internal_Error(request);
    });
  }

  void updatePlaylist(HttpRequest request) {
    int playlistId = intPathParameter(request.uri, 'playlist');
    extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updatePlaylist(
          playlistId,
          data['name'],
          data['path'],
          data['shuffle'],
          data['channels'],
          data['interval'],
          data['chimelist'],
          data['chimefreq'],
          data['chimemax']) )
      .then((int id) => writeAndCloseJson(request, playlistIdAsJson(id)))
      .catchError((error) {
        logger.error('updatePlaylist url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
      });
  }
}
