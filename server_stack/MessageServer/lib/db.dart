library messageserver.db;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql.dart';
import 'package:postgresql/postgresql_pool.dart';

import 'package:Utilities/common.dart';
import 'configuration.dart';

part 'db/getdraft.dart';
part 'db/getmessagelist.dart';
part 'db/sendmessage.dart';

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
