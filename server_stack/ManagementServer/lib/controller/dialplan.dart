library dialplanController;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../configuration.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/audiofile.dart';
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
}
