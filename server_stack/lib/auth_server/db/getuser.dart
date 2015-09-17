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

part of openreception.authentication_server.database;

Future<Map> getUser(String userEmail) {
  String sql = '''
SELECT 
  u.id, 
  u.name, 
  u.extension,
  u.google_username,
  u.google_appcode,
  u.send_from AS address, 
  coalesce (
    (SELECT array_to_json(array_agg(name)) 
     FROM user_groups JOIN groups ON user_groups.group_id = groups.id
     WHERE user_groups.user_id = u.id), 
    '[]') AS groups,
  (SELECT array_to_json(array_agg(identity)) 
   FROM auth_identities 
   WHERE user_id = u.id) AS identities
FROM auth_identities JOIN users u ON auth_identities.user_id = u.id 
WHERE identity = @email;''';

  Map parameters = {'email' : userEmail};

  return connection.query(sql, parameters).then((rows) {
    Map data = {};
    if(rows.length == 1) {
      var row = rows.first;
      data =
        {'id'              : row.id,
         'name'            : row.name,
         'address'         : row.address,
         'extension'       : row.extension,
         'groups'          : row.groups,
         'google_username' : row.google_username,
         'google_appcode'  : row.google_appcode,
         'identities'      : row.identities};
    }

    return data;
  });
}
