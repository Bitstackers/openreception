/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.database;

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:postgresql/pool.dart'       as PGPool;
import 'package:postgresql/postgresql.dart' as PG;

import 'model.dart'   as Model;
import 'storage.dart' as Storage;
import 'keys.dart'    as Key;

part 'database/conversion_functions.dart';
part 'database/database-calendar.dart';
part 'database/database-cdr.dart';
part 'database/database-contact.dart';
part 'database/database-distribution_list.dart';
part 'database/database-endpoint.dart';
part 'database/database-message.dart';
part 'database/database-message_queue.dart';
part 'database/database-organization.dart';
part 'database/database-reception.dart';
part 'database/database-user.dart';

const String libraryName = 'openreception.database';

/**
 * Database connection class. Abstracts away connection pooling.
 */
class Connection {

  ///Internal connection pool
  PGPool.Pool _pool;

  /**
   * Factory method that creates a new connection (and tests it).
   */
  static Future <Connection> connect (String dsn, {int minimumConnections: 1, int maximumConnections: 5}) {
    Connection db = new Connection._unConnected()
        .._pool = new PGPool.Pool(dsn, minConnections: minimumConnections, maxConnections: maximumConnections);

    return db._pool.start().then((_) => db._testConnection()).then((_) => db);
  }

  /**
   * Default internal named constructor. Provides an unconnected object.
   */
  Connection._unConnected();

  /**
   * Test the database connection by just opening and closing a connection.
   */
  Future _testConnection() => this._pool.connect().then((PG.Connection conn) => conn.close());

  /**
   * Close the connection
   */
  Future close() => _pool.stop();

  /**
   * Database query wrapper.
   */
  Future query(String sql, [Map parameters = null]) => this._pool.connect()
    .then((PG.Connection conn) => conn.query(sql, parameters).toList()
    .whenComplete(() => conn.close()));

  /**
   * Transaction procedure wrapper.
   */
  Future runInTransaction(Future operation()) => this._pool.connect()
    .then((PG.Connection conn) => conn.runInTransaction(operation)
    .whenComplete(() => conn.close()));

  /**
   * Execute wrapper.
   */
  Future execute(String sql, [Map parameters = null]) => this._pool.connect()
    .then((PG.Connection conn) => conn.execute(sql, parameters)
    .whenComplete(() => conn.close()));
}
