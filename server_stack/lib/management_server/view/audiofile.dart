library adaheads.server.view.contact;

import 'dart:convert';

import 'package:openreception_framework/model.dart';

String listAudiofileAsJson(List<Audiofile> files) =>
    JSON.encode({'audiofiles':_listAudiofileAsJsonList(files)});

Map _audiofileAsJsonMap(Audiofile file) => file == null ? {} :
    {'filepath': file.filepath,
     'shortname': file.shortname};

List _listAudiofileAsJsonList(List<Audiofile> files) =>
    files.map(_audiofileAsJsonMap).toList();
