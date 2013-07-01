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
Future<Response> logInfo(String message) {
  return _log(message, configuration.serverLogInterfaceInfo);
}

/**
 * Log [message] to the Error stream.
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response> logError(String message) {
  return _log(message, configuration.serverLogInterfaceError);
}

/**
 * Log [message] to the Critical stream.
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response> logCritical(String message) {
  return _log(message, configuration.serverLogInterfaceCritical);
}

/**
 * Send [message] to [url].
 *
 * Completes with
 *  On success : [Response] object with status OK (no data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response> _log(String message, Uri url) {
  assert(message.isNotEmpty);
  assert(url.isAbsolute);

  final Completer completer = new Completer<Response>();
  HttpRequest     request;
  final String    payload   = 'msg=${Uri.encodeComponent(message)}';

  request = new HttpRequest()
      ..open(POST, url.toString())
      ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
      ..onLoad.listen((_) {
        switch(request.status) {
          case 204:
            completer.complete(new Response(Response.OK, null));
            break;

          case 400:
            _logError(request, url.toString());
            Map data = _parseJson(request.responseText);
            completer.complete(new Response(Response.ERROR, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url.toString());
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send(payload);

  return completer.future;
}
