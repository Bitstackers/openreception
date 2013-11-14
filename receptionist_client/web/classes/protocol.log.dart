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
 * Log [message] to the Info stream.
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<Map>> logInfo(String message) {
  return _log(message, configuration.serverLogInterfaceInfo);
}

/**
 * Log [message] to the Error stream.
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<Map>> logError(String message) {
  return _log(message, configuration.serverLogInterfaceError);
}

/**
 * Log [message] to the Critical stream.
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<Map>> logCritical(String message) {
  return _log(message, configuration.serverLogInterfaceCritical);
}

/**
 * Send [message] to [url].
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<Map>> _log(String message, Uri url) {
  assert(message.isNotEmpty);
  assert(url.isAbsolute);

  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  HttpRequest                    request;
  final String                   payload   = 'msg=${Uri.encodeComponent(message)}';

  request = new HttpRequest()
      ..open(POST, url.toString())
      ..withCredentials = true
      ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
      ..onLoad.listen((_) {
        switch(request.status) {
          case 204:
            completer.complete(new Response<Map>(Response.OK, null));
            break;

          case 400:
            Map data = _parseJson(request.responseText);
            completer.complete(new Response<Map>(Response.ERROR, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        completer.completeError(new Response.error(Response.CRITICALERROR, '${url} ${e}'));
      })
      ..send(payload);

  return completer.future;
}
