library authenticationserver.cache;

import 'dart:async';
import 'dart:io';

import 'package:openreception_framework/cache.dart';
import 'configuration.dart';

/**
 * Loads a user token from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadToken(String id) => load('${config.cache}auth/$id.json');

Future saveToken(String id, String text) => save('${config.cache}auth/$id.json', text);

Future updateToken(String id, String text) => save('${config.cache}auth/$id.json.tmp', text).then((_) => rename('${config.cache}auth/$id.json.tmp', '${config.cache}auth/$id.json'));

Future removeToken(String id) => remove('${config.cache}auth/$id.json');

Future<List<FileSystemEntity>> listTokens() => list('${config.cache}auth');

Future setup() => createCacheFolder('${config.cache}auth/');
