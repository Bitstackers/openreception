library messageserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'model.dart';
import 'package:Utilities/common.dart';
import 'package:Utilities/database.dart' as database;

part 'db/message-draft-create.dart';
part 'db/message-draft-delete.dart';
part 'db/message-draft-update.dart';
part 'db/message-draft-list.dart';
part 'db/message-draft-single.dart';

part 'db/message-list.dart';
part 'db/message-single.dart';
part 'db/message-send.dart';

Pool _pool;

final String packageName = "messageserver.database";

class NotFound extends StateError {
  NotFound(String message) : super(message);
}

class CreateFailed extends StateError {
  CreateFailed (String message) : super(message);
}


Future startDatabase() => 
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});
