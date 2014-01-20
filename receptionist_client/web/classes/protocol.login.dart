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

/**
 * Sends a request to login
 *
 * Completes with:
 *  On success: [Response] object with status OK
 *  On error  : [Response] object with status ERROR or CRITICALERROR
 */
Future<Response<Map>> login(int userId) {
  //TODO
  final String                   base      = configuration.authBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/login';
  HttpRequest                    request;
  String                         url;

  fragments.add('user=${userId}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(GET, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
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
 * Get a list of every user.
 *
 * Completes with:
 *  On success: [Response] object with status OK
 *  On error  : [Response] object with status ERROR or CRITICALERROR
 */
Future<Response<Map>> userslist() {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/user/list';
  HttpRequest                    request;
  String                         url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(GET, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        default:
          completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
      }
    })
    ..onError.listen((e) {
      _logError(request, url);
      Map data = {'users': [{'user': {'name': "these aren't the droids"}}]};
      completer.complete(new Response<Map>(Response.OK, data));
      //completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));

    })
    ..send();

  return completer.future;
}
