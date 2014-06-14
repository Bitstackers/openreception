library userserver.database;

import 'dart:async';
import 'dart:convert';

import '../configuration.dart';
import 'package:Utilities/database.dart' as database;

//part 'database-user.dart';

database.Database db;

Future startDatabase() =>
    database.Database.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}').then((database.Database
        databaseHandle) {db = databaseHandle;});
