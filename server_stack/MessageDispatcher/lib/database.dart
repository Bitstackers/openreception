library messagedispatcher.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/database.dart' as database;

import 'model.dart' as Model;

part 'db/message-queue-list.dart';
part 'db/message-queue-single.dart';
part 'db/message-single.dart';
part 'db/database-message.dart';

Pool _pool;

const String libraryName = "messagedispatcher.database";

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
