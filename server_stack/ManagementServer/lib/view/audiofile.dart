library adaheads.server.view.contact;

import 'dart:convert';

import '../model.dart';

String listAudiofileAsJson(List<Audiofile> files) =>
    JSON.encode({'audiofiles':_listContactAsJsonList(files)});

Map _audiofileAsJsonMap(Audiofile file) => file == null ? {} :
    {'filepath': file.filepath,
     'shortname': file.shortname};

List _listContactAsJsonList(List<Audiofile> files) =>
    files.map(_audiofileAsJsonMap).toList();
