library userserver.database;

import 'dart:async';

import '../configuration.dart';
import 'package:openreception_framework/database.dart' as database;

database.Connection db;

Future startDatabase() =>
    database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}').then((database.Connection
        databaseHandle) {db = databaseHandle;});
