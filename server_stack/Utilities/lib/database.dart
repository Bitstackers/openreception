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


class Database {
  
  Pool _pool;
  
  static Future <Database> connect (String dsn, {int minimumConnections: 1, int maximumConnections: 5}) {
    Database db = new Database._stub();
    db._pool = new Pool(dsn, min: minimumConnections, max: maximumConnections);
    return db._pool.start().then((_) => db._testConnection()).then((_) => db);
  }
  
  Database._stub();

  Future _testConnection() => this._pool.connect().then((Connection conn) => conn.close());
  
  Future query(String sql, [Map parameters = null]) => this._pool.connect()
    .then((Connection conn) => conn.query(sql, parameters).toList()
    .whenComplete(() => conn.close()));

  Future execute(String sql, [Map parameters = null]) => this._pool.connect()
    .then((Connection conn) => conn.execute(sql, parameters)
    .whenComplete(() => conn.close()));

}