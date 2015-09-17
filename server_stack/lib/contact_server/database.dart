/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.contact_server.database;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/model.dart'    as Model;
import 'package:openreception_framework/keys.dart'     as Key;
import 'package:openreception_framework/storage.dart'  as Storage;
import 'package:openreception_framework/util.dart'     as Util;
import 'configuration.dart';

part 'db/contact-calendar.dart';

const String libraryName = 'contactserver.database';

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
