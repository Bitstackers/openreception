library cache;

import 'dart:async';
import 'dart:io';

import '../../Shared/cache.dart';
import '../../Shared/common.dart';
import 'configuration.dart';

/**
 * Loads a organization from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadOrganization(int id) => load('${config.cache}org/$id.json');

Future<bool> saveOrganization(int id, String text) => save('${config.cache}org/$id.json', text);

Future<bool> removeOrganization(int id) => remove('${config.cache}org/$id.json');

Future setup() {
  String path = '${config.cache}org/';
  Directory dir = new Directory(path);
    
  //First clear cache, then make the folder again.
  return dir.delete(recursive: true).catchError((e) => log('Cache clearing error: $e')).whenComplete(dir.create);
}
