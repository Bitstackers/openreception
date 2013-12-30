library cache;

import 'dart:async';
import 'dart:io';

import '../../Shared/cache.dart';
import 'configuration.dart';

/**
 * Loads a organization from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadContact(int orgId, int contactId) => load('${config.cache}contact/${orgId}_${contactId}.json');

Future<bool> saveContact(int orgId, int contactId, String text) => save('${config.cache}contact/${orgId}_${contactId}.json', text);

Future<bool> removeContact(int orgId, int contactId) => remove('${config.cache}contact/${orgId}_${contactId}.json');

Future setup() {
  String path = '${config.cache}contact/';
  Directory dir = new Directory(path);
  return dir.create();
}
