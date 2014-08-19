library receptionserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as database;

part 'db/getreception.dart';
part 'db/getcalendar.dart';
part 'db/createreception.dart';
part 'db/deletereception.dart';
part 'db/updatereception.dart';
part 'db/getreceptionlist.dart';
part 'db/reception-calendar.dart';

Pool _pool;

Future startDatabase() =>
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});
