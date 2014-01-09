library utilities.cache;

import 'dart:async';
import 'dart:io';

import 'common.dart';

Future<String> load(String path) {
  Completer completer = new Completer();
  File file = new File(path);

  file.readAsString().then((String text) {
    completer.complete(text);

  }).catchError((error) {
    log(error.toString());
    completer.complete(null);
  });

  return completer.future;
}

Future<bool> save(String path, String text) {
  Completer completer = new Completer();

  File file = new File(path);

  file.writeAsString(text)
    .then((_) => completer.complete(true))
    .catchError((error) {
      log(error.toString());
      completer.complete(false);
    });

  return completer.future;
}

Future<bool> remove(String path) {
  Completer completer = new Completer();
  File file = new File(path);

  file.delete()
    .then((_) => completer.complete(true))
    .catchError((error) {
      log(error.toString());
      completer.complete(false);
    });

  return completer.future;
}
