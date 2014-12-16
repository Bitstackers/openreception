library receptionserver.database;

import 'dart:async';
import 'dart:convert';

import 'configuration.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as Database;

part 'db/getreception.dart';
part 'db/getcalendar.dart';
part 'db/createreception.dart';
part 'db/deletereception.dart';
part 'db/updatereception.dart';
part 'db/getreceptionlist.dart';
part 'db/reception-calendar.dart';

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
