library userserver.database;

import 'dart:async';

import '../configuration.dart';
import 'package:OpenReceptionFramework/database.dart' as database;

database.Database db;

Future startDatabase() =>
    database.Database.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}').then((database.Database
        databaseHandle) {db = databaseHandle;});
