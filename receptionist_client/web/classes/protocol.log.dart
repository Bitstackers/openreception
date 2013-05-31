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

Future<Response> logInfo(String message){
  return _log(message, configuration.serverLogInterfaceInfo);
}

Future<Response> logError(String message){
  return _log(message, configuration.serverLogInterfaceError);
}

Future<Response> logCritical(String message){
  return _log(message, configuration.serverLogInterfaceCritical);
}

Future<Response> _log(String message, Uri url){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  if (message == null){
    log.critical('Protocol.Log: message is null');
    throw new Exception();
  }

  if (url == null){
    log.critical('Protocol.Log: url is null');
    throw new Exception();
  }

  String payload = 'msg=${encodeUriComponent(message)}';

  request = new HttpRequest()
      ..open(POST, url.toString())
      ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
      ..onLoad.listen((_) {
        switch(request.status) {
          case 204:
            // We do not care about success.
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
