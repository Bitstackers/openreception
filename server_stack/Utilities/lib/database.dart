library utilities.database;

import 'dart:async';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

Future query(Pool pool, String sql, [Map parameters = null]) => pool.connect()
  .then((Connection conn) => conn.query(sql, parameters).toList()
  .whenComplete(() => conn.close()));

Future execute(Pool pool, String sql, [Map parameters = null]) => pool.connect()
  .then((Connection conn) => conn.execute(sql, parameters)
  .whenComplete(() => conn.close()));

Future<Pool> start(String user, String password, String host, int port, String database, {int minimumConnections: 1, int maximumConnections: 2}) {
  String connectString = 'postgres://${user}:${password}@${host}:${port}/${database}';

  Pool pool = new Pool(connectString, min: minimumConnections, max: maximumConnections);
  return pool.start().then((_) => _testConnection(pool)).then((_) => pool);
}

Future _testConnection(Pool pool) => pool.connect().then((Connection conn) => conn.close());
