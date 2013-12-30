library cache;

import 'dart:async';
import 'dart:io';

import '../../Shared/common.dart';
import 'configuration.dart';

/**
 * Loads a organization from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadOrganization(int id) {
  Completer completer = new Completer();
  String path = '${config.cache}org/$id.json';
  File file = new File(path);

  file.readAsString().then((String text) {
    completer.complete(text);

  }).catchError((error) {
    log(error.toString());
    completer.complete(null);
  });

  return completer.future;
}

Future<bool> saveOrganization(int id, String text) {
  Completer completer = new Completer();
  String path = '${config.cache}org/$id.json';

  File file = new File(path);

  file.writeAsString(text)
    .then((_) => completer.complete(true))
    .catchError((error) {
      log(error.toString());
      completer.complete(false);
    });

  return completer.future;
}

Future<bool> removeOrganization(int id) {
  Completer completer = new Completer();
  String path = '${config.cache}org/$id.json';
  File file = new File(path);

  file.delete()
    .then((_) => completer.complete(true))
    .catchError((error) {
      log(error.toString());
      completer.complete(false);
    });

  return completer.future;
}

Future check() {
  Completer completer = new Completer();
  Directory dir = new Directory(config.cache);

  dir.exists().then((bool exists) {
    if(exists == false || !config.cache.endsWith('/')) {
      completer.completeError('Cache location is not valid');

    } else {
      _makeCacheStructure()
        .then((_) => completer.complete())
        .catchError((error) => completer.completeError(error));
    }
  }).catchError((error) => completer.completeError(error));

  return completer.future;
}

Future _makeCacheStructure() {
  String path = '${config.cache}org/';
  Directory dir = new Directory(path);
  return dir.create();
}
