library tools;

import 'dart:async';

import 'package:openreception_framework/database.dart' as Database;

const String dbDSN ='postgres://user:pass@localhost:5432/openreception';

final Duration maxAge = new Duration(days : 30);

Future main() async {
  Database.Connection connection = await Database.Connection.connect(dbDSN);

  DateTime cutOffDate = new DateTime.now().subtract(maxAge);

  const String sql = 'DELETE FROM calendar_events WHERE stop < @cutOffDate';

  Map parameters = {
    'cutOffDate' : cutOffDate
  };

  await connection.execute(sql, parameters).then((int affectedRows) {
    print('Removed $affectedRows old calendar entries');
  });

  await connection.close();

}
