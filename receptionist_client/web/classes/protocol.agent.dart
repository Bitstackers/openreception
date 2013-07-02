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
 * Get state for [agentId].
 *
 * Completes with
 *  On success   : [Response] object with status OK (data)
 *  On not found : [Response] object with status NOTFOUND (no data)
 *  On error     : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response> getAgentState(int agentId){
  assert(agentId != null);

  final String       base      = configuration.aliceBaseUrl.toString();
  final Completer    completer = new Completer<Response>();
  final List<String> fragments = <String>[];
  final String       path      = '/agent/state';
  HttpRequest        request;
  String             url;

  fragments.add('agent_id=${agentId}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((_) {
        switch(request.status) {
          case 200:
            Map data = _parseJson(request.responseText);
            completer.complete(new Response(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response(Response.NOTFOUND, null));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e){
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}

/**
 * Set state for [agentId].
 *
 * Completes with
 *  On success   : [Response] object with status OK (data)
 *  On not found : [Response] object with status NOTFOUND (no data)
 *  On error     : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response> setAgentState(int agentId){
  assert(agentId != null);

  final String       base      = configuration.aliceBaseUrl.toString();
  final Completer    completer = new Completer<Response>();
  final List<String> fragments = <String>[];
  final String       path      = '/agent/state';
  HttpRequest        request;
  String             url;

  fragments.add('agent_id=${agentId}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(POST, url)
      ..onLoad.listen((_) {
        switch(request.status) {
          case 200:
            Map data = _parseJson(request.responseText);
            completer.complete(new Response(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response(Response.NOTFOUND, null));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e){
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}

/**
 * Get a list of agents.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  On error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response> agentList(){
  final String    base      = configuration.aliceBaseUrl.toString();
  final Completer completer = new Completer<Response>();
  final String    path      = '/agent/list';
  HttpRequest     request;
  final String    url       = _buildUrl(base, path);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((_) {
        switch(request.status) {
          case 200:
            Map data = _parseJson(request.responseText);
            completer.complete(new Response(Response.OK, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e){
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      });
      //..send();  // TODO Remove this when alice is ready.

  // Some testing data.
  //"idle | busy | paused | logged out | ???"
  final Map testData =
    {"Agents":[{"id": 1,  "state": "idle"},
               {"id": 2,  "state": "idle"},
               {"id": 3,  "state": "busy"},
               {"id": 4,  "state": "idle"},
               {"id": 5,  "state": "idle"},
               {"id": 6,  "state": "busy"},
               {"id": 8,  "state": "idle"},
               {"id": 10, "state": "paused"},
               {"id": 11, "state": "paused"},
               {"id": 13, "state": "logged out"}]};

  completer.complete(new Response(Response.OK, testData));

  return completer.future;
}
