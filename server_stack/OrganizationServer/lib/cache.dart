library organizationserver.cache;

import 'dart:async';

import 'package:Utilities/cache.dart' ;
import 'configuration.dart';

/**
 * Loads a organization from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadOrganization(int id) => load('${config.cache}org/$id.json');

Future<bool> saveOrganization(int id, String text) => save('${config.cache}org/$id.json', text);

Future<bool> removeOrganization(int id) => remove('${config.cache}org/$id.json');

Future setup() => createCacheFolder('${config.cache}org/');
