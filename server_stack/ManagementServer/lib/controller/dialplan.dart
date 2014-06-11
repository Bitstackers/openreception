library dialplanController;

import 'dart:io';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/audiofile.dart';

class DialplanController {
  Database db;

  DialplanController(Database this.db);

  void getAudiofileList(HttpRequest request) {
    db.getAudiofileList().then((List<Audiofile> Audiofiles) {
      writeAndCloseJson(request, listAudiofileAsJson(Audiofiles));
    }).catchError((error) {
      logger.error('dialplanController.getAudiofileList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}
