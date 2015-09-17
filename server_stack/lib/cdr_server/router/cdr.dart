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

void cdrHandler(HttpRequest request) {
  if(!request.uri.queryParameters.containsKey('date_from')) {
    clientError(request, 'Missing parameter: date_from');
    return;
  }
  if(!request.uri.queryParameters.containsKey('date_to')) {
    clientError(request, 'Missing parameter: date_to');
    return;
  }

  DateTime start, end;
  bool inbound;
  try {
    start = new DateTime.fromMillisecondsSinceEpoch(int.parse (request.uri.queryParameters['date_from'])*1000);
    end   = new DateTime.fromMillisecondsSinceEpoch(int.parse (request.uri.queryParameters['date_to'])*1000);
    inbound   = false;
  } catch(error) {
    clientError(request, 'Bad parameter: ${error}');
    return;
  }

  if (request.uri.queryParameters['inbound'] == "true") {
    inbound = true;
  }

  db.cdrList(inbound, start, end)
    .then((List orglist) => writeAndClose(request, JSON.encode({'cdr_stats' : orglist})))
    .catchError((error) => serverError(request, error.toString()));
}
