library utilities.cache;

import 'dart:async';
import 'dart:io';

Future<String> load(String path) => new File(path).readAsString();

Future<List<FileSystemEntity>> list(String path) {
  Directory dir = new Directory(path);
  return dir.list().toList().then((List<FileSystemEntity> values) {
    return values;
  });
}

Future remove(String path) =>  new File(path).delete();

Future rename(String path, String newPath) => new File(path).rename(newPath);

Future save(String path, String text) => new File(path).writeAsString(text);

Future createCacheFolder(String path) {
  Directory dir = new Directory(path);
    
  //First clear cache, then make the folder again.
  return dir.delete(recursive: true).catchError((_) => null).whenComplete(dir.create);
}
