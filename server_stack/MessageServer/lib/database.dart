library messageserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as database;

import 'model.dart';

import 'model.dart' as Model;

part 'db/message-draft-create.dart';
part 'db/message-draft-delete.dart';
part 'db/message-draft-update.dart';
part 'db/message-draft-list.dart';
part 'db/message-draft-single.dart';
part 'db/database-message.dart';

Pool _pool;

final String packageName = "messageserver.database";

class NotFound extends Error {
  final String message;
  NotFound(this.message);
  String toString() => "NotFound: $message";
}

class CreateFailed extends Error {
  final String message;
  CreateFailed(this.message);
  String toString() => "CreateFailed: $message";
}

Future startDatabase() =>
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});
