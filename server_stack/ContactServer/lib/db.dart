library db;

import 'dart:async';
import 'dart:convert';

import 'common.dart';
import 'configuration.dart';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

part 'db/getcontact.dart';
part 'db/createcontact.dart';
part 'db/deletecontact.dart';
part 'db/updatecontact.dart';
part 'db/getcontactlist.dart';

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
