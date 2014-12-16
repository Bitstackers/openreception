library contactserver.database;

import 'dart:async';

import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as Database;
import 'configuration.dart';

part 'db/getreceptioncontact.dart';
part 'db/getreceptioncontactlist.dart';
part 'db/getcontactsphones.dart';
part 'db/getphone.dart';
part 'db/getcalendar.dart';
part 'db/contact-calendar.dart';

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
