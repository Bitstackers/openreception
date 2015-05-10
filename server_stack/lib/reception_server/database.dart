library receptionserver.database;

import 'dart:async';

import 'configuration.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/model.dart'    as Model;
import 'package:openreception_framework/storage.dart'  as Storage;
import 'package:openreception_framework/util.dart'     as Util;

part 'db/getreception.dart';
part 'db/createreception.dart';
part 'db/deletereception.dart';
part 'db/updatereception.dart';
part 'db/reception-calendar.dart';
part 'db/reception.dart';

const String libraryName = 'receptionserver.database';

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
