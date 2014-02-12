library authenticationserver.cache;

import 'dart:async';
import 'dart:io';

import 'package:Utilities/cache.dart';
import 'configuration.dart';

/**
 * Loads a user token from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadToken(String id) => load('${config.cache}auth/$id.json');

Future saveToken(String id, String text) => save('${config.cache}auth/$id.json', text);

Future removeToken(String id) => remove('${config.cache}auth/$id.json');

Future<List<FileSystemEntity>> listTokens() => list('${config.cache}auth');

Future setup() => createCacheFolder('${config.cache}auth/');
