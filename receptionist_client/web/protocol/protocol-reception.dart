/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of protocol;

const String MINI = 'mini';
const String MIDI = 'midi';

/**
 * Get the reception calendar JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.CalendarEventList>> getReceptionCalendar(int id) {
  final String       base      = configuration.receptionBaseUrl.toString();
  final Completer<Response<model.CalendarEventList>> completer =
      new Completer<Response<model.CalendarEventList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/reception/$id/calendar';
  HttpRequest        request;
  String             url;
  
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            var response = _parseJson(request.responseText);
            model.CalendarEventList data = new model.CalendarEventList.fromMap(response, 'CalendarEvents');
            completer.complete(new Response<model.CalendarEventList>(Response.OK, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}

/**
 * Get the reception list JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.ReceptionList>> getReceptionList() {
  final String       base      = configuration.receptionBaseUrl.toString();
  final Completer<Response<model.ReceptionList>> completer =
      new Completer<Response<model.ReceptionList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/reception';
  HttpRequest        request;
  String             url;
  
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            var response = _parseJson(request.responseText);
            model.ReceptionList data = new model.ReceptionList.fromJson(response, 'reception_list');
            completer.complete(new Response<model.ReceptionList>(Response.OK, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}