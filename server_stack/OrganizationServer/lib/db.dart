library db;

import 'dart:async';
import 'dart:convert';

import '../../Shared/common.dart';
import 'configuration.dart';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

part 'db/getorganization.dart';
part 'db/getcalendar.dart';
part 'db/createorganization.dart';
part 'db/deleteorganization.dart';
part 'db/updateorganization.dart';
part 'db/getorganizationlist.dart';

String _connectString;
Pool   _pool;

Future startDatabase() {
  _connectString = 'postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}';

  _pool          = new Pool(_connectString, min: 1, max: 2);
  return _pool.start().then((_) => _testConnection());
}

Future _testConnection() {
  return _pool.connect().then((Connection conn) {
    conn.close();
    log('Database connection established.');
  })
  .catchError((error) {
    log('Database error');
    throw error;
  });
}
