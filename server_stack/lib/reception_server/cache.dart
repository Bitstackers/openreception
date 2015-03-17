library receptionserver.cache;

import 'dart:async';

import 'package:openreception_framework/cache.dart' ;
import 'configuration.dart';

/**
 * Loads a reception from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadReception(int id) => load('${config.cache}reception/$id.json');

Future<bool> saveReception(int id, String text) => save('${config.cache}reception/$id.json', text);

Future<bool> removeReception(int id) => remove('${config.cache}reception/$id.json');

Future setup() => createCacheFolder('${config.cache}reception/');
