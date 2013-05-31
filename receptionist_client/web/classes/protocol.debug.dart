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
 * Gives a list of peers.
 */
Future<Response> peerList(){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/debug/peer/list';

  String url = _buildUrl(base, path);
  request = new HttpRequest()
    ..open(GET, url)
    ..onLoad.listen((_){
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
    ..onError.listen((e) {
      _logError(request, url);
      completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));

    })
    ..send();

  return completer.future;
}

/**
 * Gives a list of every channel in the PBX.
 */
Future<Response> channelList(){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/debug/channel/list';

  String url = _buildUrl(base, path);
  request = new HttpRequest()
    ..open(GET, url)
    ..onLoad.listen((_){
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
    ..onError.listen((e) {
      _logError(request, url);
      completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));

    })
    ..send();

  return completer.future;
}
