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

library openreception.filestore;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

import 'model.dart' as model;
import 'storage.dart' as storage;

part 'filestore/filestore-calendar.dart';
part 'filestore/filestore-contact.dart';
part 'filestore/filestore-git_engine.dart';
part 'filestore/filestore-ivr.dart';
part 'filestore/filestore-message_queue.dart';
part 'filestore/filestore-message.dart';
part 'filestore/filestore-organization.dart';
part 'filestore/filestore-reception_dialplan.dart';
part 'filestore/filestore-reception.dart';
part 'filestore/filestore-user.dart';

const String libraryName = 'openreception.filestore';

final JsonEncoder _jsonpp = new JsonEncoder.withIndent('  ');

final Uuid _uuid = new Uuid();
final model.User _systemUser = new model.User.empty()
  ..name = 'System'
  ..address = 'root@localhost';

/**
 * Generate an author string.
 */
String _authorString(model.User user) =>
    new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert('${user.name}') +
    ' <${user.address}>';
