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
Future<Response> getAgentState(int agentId){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/agent/state';
  List<String> fragments = new List<String>();

  if (agentId == null){
    log.critical('Protocol.getAgentState: agentId is null');
    throw new Exception();
  }

  fragments.add('agent_id=${agentId}');

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
      ..open(GET, url)
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
 * TODO Comment
 */
Future<Response> setAgentState(int agentId){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/agent/state';
  List<String> fragments = new List<String>();

  if (agentId == null){
    log.critical('Protocol.setAgentState: agentId is null');
    throw new Exception();
  }

  fragments.add('agent_id=${agentId}');

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
      ..open(POST, url)
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
 * Sends a request for a list of agents.
 */
Future<Response> agentList(){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/agent/list';

  String url = _buildUrl(base, path);
  request = new HttpRequest()
      ..open(GET, url)
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
      });
      //..send();  //TODO Remove this when alice is ready.

  //"idle | busy | paused | logged out | ???"
  final Map testData =
    {"Agents" :
      [
       {"id": 1, "state": "idle"},
       {"id": 2, "state": "idle"},
       {"id": 3, "state": "busy"},
       {"id": 4, "state": "idle"},
       {"id": 5, "state": "idle"},
       {"id": 6, "state": "busy"},
       {"id": 8, "state": "idle"},
       {"id": 10, "state": "paused"},
       {"id": 11, "state": "paused"},
       {"id": 13, "state": "logged out"}
       ]};

  completer.complete(new Response(Response.OK, testData));

  return completer.future;
}
