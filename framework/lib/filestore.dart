/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.framework.filestore;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'package:openreception.framework/bus.dart';
import 'package:openreception.framework/gzip_cache.dart'
    show unpackAndDeserializeObject, serializeAndCompressObject;

import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:path/path.dart';

part 'filestore/filestore-agent_history.dart';
part 'filestore/filestore-calendar.dart';
part 'filestore/filestore-contact.dart';
part 'filestore/filestore-git_engine.dart';
part 'filestore/filestore-ivr.dart';
part 'filestore/filestore-message.dart';
part 'filestore/filestore-message_queue.dart';
part 'filestore/filestore-organization.dart';
part 'filestore/filestore-reception.dart';
part 'filestore/filestore-reception_dialplan.dart';
part 'filestore/filestore-sequencer.dart';
part 'filestore/filestore-user.dart';

const String libraryName = 'openreception.filestore';

final JsonEncoder _jsonpp = new JsonEncoder.withIndent('  ');

final model.User _systemUser = new model.User.empty()
  ..name = 'System'
  ..address = 'root@localhost';

/**
 * Generate an author string.
 */
String _authorString(model.User user) =>
    new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert('${user.name}') +
    ' <${user.address}>';

/**
 * Convenience functions
 */
bool isFile(FileSystemEntity fse) => fse is File && !fse.path.startsWith('.');

bool isJsonFile(FileSystemEntity fse) =>
    fse is File && !fse.path.startsWith('.') && fse.path.endsWith('.json');

bool isDirectory(FileSystemEntity fse) =>
    !basename(fse.path).startsWith('.') && fse is Directory;

class DataStore {
  final Calendar calendarStore;
  final Contact contactStore;
  final Ivr ivrStore;
  final Message messageStore;
  final Organization organizationStore;
  final Reception receptionStore;
  final ReceptionDialplan receptionDialplanStore;
  final User userStore;

  /**
   *
   */
  factory DataStore(String path, [GitEngine ge]) {
    Calendar calendarStore = new Calendar(path + '/calendar', ge);
    Reception receptionStore = new Reception(path + '/reception', ge);
    Contact contactStore = new Contact(receptionStore, path + '/contact', ge);
    Ivr ivrStore = new Ivr(path + '/ivr', ge);
    Message messageStore = new Message(path + '/message');
    Organization orgStore = new Organization(
        contactStore, receptionStore, path + '/organization', ge);
    ReceptionDialplan receptionDialplanStore =
        new ReceptionDialplan(path + '/dialplan', ge);
    User userStore = new User(path + '/user', ge);

    return new DataStore._internal(
        calendarStore,
        contactStore,
        ivrStore,
        messageStore,
        orgStore,
        receptionStore,
        receptionDialplanStore,
        userStore);
  }

  /**
   *
   */
  DataStore._internal(
      Calendar this.calendarStore,
      Contact this.contactStore,
      Ivr this.ivrStore,
      Message this.messageStore,
      Organization this.organizationStore,
      Reception this.receptionStore,
      ReceptionDialplan this.receptionDialplanStore,
      User this.userStore);
}

/**
 *
 */
class ChangeLogger {
  final File logFile;
  final Logger _log =
      new Logger('openreception.framework.filestore.ChangeLogger');

  /**
   *
   */
  ChangeLogger(String filepath)
      : logFile = new File(filepath + '/changes.log') {
    try {
      if (!logFile.existsSync()) {
        logFile.createSync();
      }
    } on FileSystemException catch (e) {
      _log.warning('Failed to create changelogfile', e);
    }
  }

  /**
   *
   */
  void add(model.ChangelogEntry object) {
    logFile.writeAsStringSync(JSON.encode(object) + '\n',
        mode: FileMode.APPEND);
  }

  /**
   *
   */
  Future<String> contents() async => new File(logFile.path).existsSync()
      ? (await new File(logFile.path).readAsString())
      : '';
}
