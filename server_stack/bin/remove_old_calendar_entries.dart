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

library openreception.tools;

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
