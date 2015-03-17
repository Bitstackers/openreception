library authenticationserver.database;

import 'dart:async';

import 'configuration.dart';
import 'package:openreception_framework/database.dart' as Database;

part 'db/getuser.dart';

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
