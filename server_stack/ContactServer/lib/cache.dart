library contactserver.cache;

import 'dart:async';

import 'package:OpenReceptionFramework/cache.dart';
import 'configuration.dart';

const _folderName = 'contact';

/**
 * Loads a contact from cache.
 * if it don't exists, then null is returned.
 */
Future<String> loadContact(int receptionId, int contactId) => load('${config.cache}${_folderName}/${receptionId}_${contactId}.json');

Future<bool> saveContact(int receptionId, int contactId, String text) => save('${config.cache}${_folderName}/${receptionId}_${contactId}.json', text);

Future<bool> removeContact(int receptionId, int contactId) => remove('${config.cache}${_folderName}/${receptionId}_${contactId}.json');

Future setup() => createCacheFolder('${config.cache}${_folderName}/');
