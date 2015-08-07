library cdrserver.database;

import 'dart:async';

import 'configuration.dart';
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as Database;


part 'db/cdr.dart';
part 'db/create_checkpoint.dart';
part 'db/get_checkpoint_list.dart';
part 'db/newcdr.dart';

final String libraryName = "cdrserver.database";

class NotFound extends StateError {
  NotFound(String message) : super(message);
}

class CreateFailed extends StateError {
  CreateFailed (String message) : super(message);
}

Database.Connection connection = null;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
