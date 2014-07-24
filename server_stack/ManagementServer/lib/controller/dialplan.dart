library dialplanController;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import '../configuration.dart';
import '../database.dart';
import '../model.dart';
import '../view/audiofile.dart';
import '../view/dialplan.dart';
import '../view/dialplan_template.dart';
import '../view/playlist.dart';
import '../view/ivr.dart';
import '../service.dart' as service;
import 'package:OpenReceptionFramework/common.dart' as orf;
import 'package:OpenReceptionFramework/httpserver.dart' as orf_http;

const libraryName = 'dialplanController';

class DialplanController {
  Database db;
  Configuration config;

  DialplanController(Database this.db, Configuration this.config);

  void getAudiofileList(HttpRequest request) {
    const context = '${libraryName}.getAudiofileList';

    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    String token = request.uri.queryParameters['token'];

    service.getAudioFileList(config.dialplanCompilerServer, receptionId, token).then((http.Response response) {
      if(response.statusCode == 200) {
        List<String> files = JSON.decode(response.body)['files'];
        List<Audiofile> audioFiles = files.map((String file) => new Audiofile(file, file.split('/').last)).toList();
        return orf_http.writeAndClose(request, listAudiofileAsJson(audioFiles));
      } else {
        request.response.statusCode = response.statusCode;
        return orf_http.writeAndClose(request, response.body);
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: ${error}', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getDialplan(HttpRequest request) {
    const context = '${libraryName}.getDialplan';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getDialplan(receptionId)
      .then((Dialplan dialplan) => orf_http.writeAndClose(request, dialplanAsJson(dialplan)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void updateDialplan(HttpRequest request) {
    const context = '${libraryName}.updateDialplan';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    String token = request.uri.queryParameters['token'];

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateDialplan(receptionId, data))
      .then((_) => service.compileDialplan(config.dialplanCompilerServer, receptionId, token))
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void getIvr(HttpRequest request) {
    const context = '${libraryName}.getIvr';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getIvr(receptionId)
      .then((IvrList ivrList) => orf_http.writeAndClose(request, ivrListAsJson(ivrList)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void updateIvr(HttpRequest request) {
    const context = '${libraryName}.updateIvr';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    String token = request.uri.queryParameters['token'];

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateIvr(receptionId, data))
      .then((_) => service.compileIvrMenu(config.dialplanCompilerServer, receptionId, token))
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void getPlaylists(HttpRequest request) {
    const context = '${libraryName}.updateIvr';

    db.getPlaylistList()
      .then((List<Playlist> playlists) => orf_http.writeAndClose(request, playlistListAsJson(playlists)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void createPlaylist(HttpRequest request) {
    const context = '${libraryName}.createPlaylist';

    orf_http.extractContent(request)
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
      .then((int id) => orf_http.writeAndClose(request, playlistIdAsJson(id)))
      .catchError((error, stack) {
        orf.logger.errorContext('error: $error ${stack}', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deletePlaylist(HttpRequest request) {
    const context = '${libraryName}.deletePlaylist';
    int playlistId = orf_http.pathParameter(request.uri, 'playlist');

    db.deletePlaylist(playlistId)
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void getPlaylist(HttpRequest request) {
    const context = '${libraryName}.getPlaylist';
    int playlistId = orf_http.pathParameter(request.uri, 'playlist');

    db.getPlaylist(playlistId).then((Playlist playlist) {
      if(playlist == null) {
        request.response.statusCode = 404;
        return orf_http.writeAndClose(request, JSON.encode({}));
      } else {
        return orf_http.writeAndClose(request, playlistAsJson(playlist));
      }
    }).catchError((error, stack) {
      orf.logger.errorContext('Error: "$error" "${stack}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updatePlaylist(HttpRequest request) {
    const context = '${libraryName}.updatePlaylist';
    int playlistId = orf_http.pathParameter(request.uri, 'playlist');

    orf_http.extractContent(request)
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
      .then((int id) => orf_http.writeAndClose(request, playlistIdAsJson(id)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void getTemplates(HttpRequest request) {
    const context = '${libraryName}.getTemplates';

    db.getDialplanTemplates().then((List<DialplanTemplate> templates) {
      return orf_http.writeAndClose(request, dialplanTemplateListAsJson(templates));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }
}
