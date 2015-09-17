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

part of openreception.cdr_server.router;

void insertCdrData(HttpRequest request) {
  //AUTH
  //Check if the shared Secret is matching, and the whitelisted IPs.

  extractContent(request).then((String content) {
    Map json;
    try {
      json = JSON.decode(content);
    } catch(error) {
      clientError(request, 'Malformed json');
      return new Future.value();
    }

    Model.FreeSWITCHCDREntry entry;
    try {
      entry = new Model.FreeSWITCHCDREntry.fromJson(json);
    } catch(error) {
      clientError(request, 'Missing document field. ${error}');
      return new Future.value();
    }

    return db.newcdrEntry(entry).then((_) {
      allOk(request);
    });
  }).catchError((error, stack) {
    serverError(request, 'Error: "${error}", stack: \n"${stack}"');
  });
}
