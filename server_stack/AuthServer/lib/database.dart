library authenticationserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'package:Utilities/database.dart' as database;

part 'db/getuser.dart';

Pool _pool;

Future startDatabase() => 
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});
