library utilities.cache;

import 'dart:async';
import 'dart:io';

Future<String> load(String path) => new File(path).readAsString();

Future remove(String path) =>  new File(path).delete();

Future save(String path, String text) => new File(path).writeAsString(text);

Future createCacheFolder(String path) {
  Directory dir = new Directory(path);
    
  //First clear cache, then make the folder again.
  return dir.delete(recursive: true).catchError((_) => null).whenComplete(dir.create);
}
