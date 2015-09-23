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

library openreception.cdr_server.database;

import 'dart:async';

import '../configuration.dart';
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/database.dart' as Database;
import 'package:logging/logging.dart';

part 'db/cdr.dart';
part 'db/create_checkpoint.dart';
part 'db/get_checkpoint_list.dart';
part 'db/newcdr.dart';

final Logger _log = new Logger ("cdrserver.database");

class NotFound extends StateError {
  NotFound(String message) : super(message);
}

class CreateFailed extends StateError {
  CreateFailed (String message) : super(message);
}

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect(config.database.dsn)
      .then((Database.Connection newConnection) => connection = newConnection);
