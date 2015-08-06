library contactserver.database;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/model.dart'    as Model;
import 'package:openreception_framework/keys.dart'     as Key;
import 'package:openreception_framework/storage.dart'  as Storage;
import 'package:openreception_framework/util.dart'     as Util;
import 'configuration.dart';

part 'db/contact.dart';
part 'db/contact-calendar.dart';

const String libraryName = 'contactserver.database';

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
