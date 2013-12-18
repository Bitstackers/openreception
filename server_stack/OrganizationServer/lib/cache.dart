library cache;

import 'dart:async';
import 'dart:io';

import 'common.dart';

/**
 * Loads a organization from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadOrganization(int id) {
  Completer completer = new Completer();
  String path = '/dev/shm/org/$id.json';
  File file = new File(path);

  file.readAsString().then((String text) {
    completer.complete(text);

  }).catchError((_) {
    completer.complete(null);
  });

  return completer.future;
}

Future saveOrganization(int id, String text) {
  Completer completer = new Completer();
  String path = '/dev/shm/org/$id.json';

  File file = new File(path);

  file.writeAsString(text)
    .then((_) => completer.complete(true))
    .catchError((error) {
      log(error.toString());
      completer.complete(false);
    });

  return completer.future;
}

Future removeOrganization(int id) {
  Completer completer = new Completer();
  String path = '/dev/shm/org/$id.json';
  File file = new File(path);

  file.delete()
    .then((_) => completer.complete(true))
    .catchError((_) => completer.complete(false));

  return completer.future;
}
