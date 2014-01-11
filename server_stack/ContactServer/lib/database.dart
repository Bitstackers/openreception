library contactserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql.dart';
import 'package:postgresql/postgresql_pool.dart';

import 'package:Utilities/common.dart';
import 'package:Utilities/database.dart' as database;
import 'configuration.dart';

part 'db/getorganizationcontact.dart';
part 'db/getorganizationcontactlist.dart';
part 'db/getphone.dart';
part 'db/getcalendar.dart';

Pool _pool;

Future startDatabase() => 
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});
