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
 * TODO Comment
 */
Future<Response> sendMessage(int cmId, String message) {
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/message/send';

  if (cmId == null){
    log.critical('Protocol.Message: cmId is null');
    throw new Exception();
  }

  if (message == null){
    log.critical('Protocol.Message: message is null');
    throw new Exception();
  }

  String url = _buildUrl(base, path);
  String payload = 'cm_id=${cmId}&msg=${Uri.encodeComponent(message)}';

  request = new HttpRequest()
  ..open(POST, url)
  ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
  ..onLoad.listen((_) {
    switch(request.status) {
      case 200:
        Map data = _parseJson(request.responseText);
        if (data != null) {
          completer.complete(new Response(Response.OK, data));
        } else {
          completer.complete(new Response(Response.ERROR, data));
        }
        break;

      default:
        completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
    }
  })
  ..onError.listen((e){
    _logError(request, url);
    completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
  })
  ..send(payload);

  return completer.future;
}
