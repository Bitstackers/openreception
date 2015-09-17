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

library openreception.management_server.controller.dialplan;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';
import 'package:path/path.dart' as path;

import '../configuration.dart';
import '../database.dart';
import 'package:openreception_framework/model.dart';
import '../view/audiofile.dart';
import '../view/dialplan.dart';
import '../view/dialplan_template.dart';
import '../view/playlist.dart';
import '../view/ivr.dart';
import '../service.dart' as service;
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'dialplanController';

class DialplanController {
  final Database db;
  final Configuration config;

  DialplanController(Database this.db, Configuration this.config);

  void getAudiofileList(HttpRequest request) {
    const String context = '${libraryName}.getAudiofileList';

    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final String token = request.uri.queryParameters['token'];

    service.getAudioFileList(config.dialplanCompilerServer, receptionId, token).then((http.Response response) {
      if(response.statusCode == 200) {
        List<String> files = JSON.decode(response.body)['files'];
        List<Audiofile> audioFiles = files.map((String file) => new Audiofile(file, file.split('/').last)).toList();
        return orf_http.writeAndClose(request, listAudiofileAsJson(audioFiles));
      } else {
        request.response.statusCode = response.statusCode;
        return orf_http.writeAndClose(request, response.body);
      }
    }).catchError((error, stack) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getDialplan(HttpRequest request) {
    const String context = '${libraryName}.getDialplan';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getDialplan(receptionId)
      .then((Dialplan dialplan) => orf_http.writeAndClose(request, dialplanAsJson(dialplan)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void updateDialplan(HttpRequest request) {
    const String context = '${libraryName}.updateDialplan';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    //final String token = request.uri.queryParameters['token'];

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map dialplanJson) => db.updateDialplan(receptionId, dialplanJson))
      .then((_) => orf_http.allOk(request))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void compileDialplan(HttpRequest request) {
    const String context = '${libraryName}.compileDialplan';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final String token = request.uri.queryParameters['token'];
    db.getDialplan(receptionId).then((Dialplan dialplan) {
      return service.compileDialplan(config.dialplanCompilerServer, receptionId, dialplanAsJson(dialplan), token);
    }).then((http.Response response) {
      if(response.statusCode == 200) {
        return db.markDialplanAsCompiled(receptionId).then((_) => orf_http.allOk(request));
      } else {
        request.response.statusCode = response.statusCode;
        return orf_http.writeAndClose(request, JSON.encode({'error': 'The compilating of the dialplan returned an error',
                                                            'description': JSON.decode(response.body)}));
      }
    }).catchError((error, stack) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
      orf_http.serverError(request, error.toString());
  });

  }

  void getIvr(HttpRequest request) {
    const String context = '${libraryName}.getIvr';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getIvr(receptionId)
      .then((IvrList ivrList) => orf_http.writeAndClose(request, ivrListAsJson(ivrList)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void updateIvr(HttpRequest request) {
    const String context = '${libraryName}.updateIvr';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final String token = request.uri.queryParameters['token'];

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map ivrMenu) => db.updateIvr(receptionId, ivrMenu)
        .then((_) => service.compileIvrMenu(config.dialplanCompilerServer, receptionId, JSON.encode(ivrMenu), token)))
      .then((_) => orf_http.allOk(request) )
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void getPlaylists(HttpRequest request) {
    const String context = '${libraryName}.updateIvr';

    db.getPlaylistList()
      .then((List<Playlist> playlists) => orf_http.writeAndClose(request, playlistListAsJson(playlists)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void createPlaylist(HttpRequest request) {
    const String context = '${libraryName}.createPlaylist';
    final String token = request.uri.queryParameters['token'];

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) =>
        db.createPlaylist(
          data['name'],
          data['path'],
          data['shuffle'],
          data['channels'],
          data['interval'],
          data['chimelist'],
          data['chimefreq'],
          data['chimemax'])
        .then((int id) => service.compilePlaylist(config.dialplanCompilerServer, id, JSON.encode(data), token)
        .then((_) => id)))
      .then((int id) => orf_http.writeAndClose(request, playlistIdAsJson(id)))
      .catchError((error, stack) {
        orf.logger.errorContext('error: $error ${stack}', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deletePlaylist(HttpRequest request) {
    const String context = '${libraryName}.deletePlaylist';
    final int playlistId = orf_http.pathParameter(request.uri, 'playlist');

    db.deletePlaylist(playlistId)
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void getPlaylist(HttpRequest request) {
    const String context = '${libraryName}.getPlaylist';
    final int playlistId = orf_http.pathParameter(request.uri, 'playlist');

    db.getPlaylist(playlistId).then((Playlist playlist) {
      if(playlist == null) {
        request.response.statusCode = 404;
        return orf_http.allOk(request);
      } else {
        return orf_http.writeAndClose(request, playlistAsJson(playlist));
      }
    }).catchError((error, stack) {
      orf.logger.errorContext('Error: "$error" "${stack}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updatePlaylist(HttpRequest request) {
    const String context = '${libraryName}.updatePlaylist';
    final int playlistId = orf_http.pathParameter(request.uri, 'playlist');
    final String token = request.uri.queryParameters['token'];

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
          data['chimemax'])
        .then((_) => service.compilePlaylist(config.dialplanCompilerServer, playlistId, JSON.encode(data), token)))
      .then((_) => orf_http.allOk(request))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void getTemplates(HttpRequest request) {
    const String context = '${libraryName}.getTemplates';

    db.getDialplanTemplates().then((List<DialplanTemplate> templates) {
      return orf_http.writeAndClose(request, dialplanTemplateListAsJson(templates));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void recordSound(HttpRequest request) {
    //const String context = '${libraryName}.getReception';
    final String token = request.uri.queryParameters['token'];
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    String filename = request.uri.queryParameters['filename'];
    if(filename == null || filename.trim().isEmpty) {
      orf_http.clientError(request, 'Missing parameter: "filename".');
      return;
    }

    String filepath = path.join(config.recordingsDirectory, receptionId.toString(), filename);

    if(!path.normalize(filepath).startsWith(config.recordingsDirectory)) {
      orf_http.clientError(request, 'As of now, are you only able to access files inside the recordingdirectory.');
      return;
    }

    service.record(config.callFlowServer, receptionId, filepath, token).then((http.Response repsonse) {
      orf_http.allOk(request);
    }).catchError((error, stack) {
      String logMessage = 'Error ${error}, Stack: ${stack}';
      orf_http.serverError(request, logMessage);
    });
  }

  void deleteSoundFile(HttpRequest request) {
    //const String context = '${libraryName}.getReception';
    final String token = request.uri.queryParameters['token'];
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    final String filename = request.uri.queryParameters['filename'];
    if(filename == null || filename.trim().isEmpty) {
      orf_http.clientError(request, 'Missing parameter: "filename".');
      return;
    }

    final String filepath = path.join(config.recordingsDirectory, receptionId.toString(), filename);

    if(!path.normalize(filepath).startsWith(config.recordingsDirectory)) {
      orf_http.clientError(request, 'As of now, are you only able to access files inside the recordingdirectory.');
      return;
    }

    service.deleteRecording(config.dialplanCompilerServer, filepath, token).then((http.Response repsonse) {
      orf_http.allOk(request);
    }).catchError((error, stack) {
      String logMessage = 'Error ${error}, Stack: ${stack}';
      orf_http.serverError(request, logMessage);
    });
  }
}
