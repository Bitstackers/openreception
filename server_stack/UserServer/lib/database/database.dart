library userserver.database;

import 'dart:async';

import '../configuration.dart';
import 'package:openreception_framework/database.dart' as Database;

Database.Connection connection;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}').then((Database.Connection
        databaseHandle) {connection = databaseHandle;});
