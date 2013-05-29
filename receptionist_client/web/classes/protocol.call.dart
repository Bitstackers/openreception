/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

part of protocol;

/**
 * Gets a list of every active call.
 */
Future<Response> callList(){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/list';

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
        case 204:
          completer.complete(new Response(Response.OK, {}));
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
 * Gives a list of calls that are waiting in a queue.
 */
Future<Response> callQueue(){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/queue';

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
        case 204:
          completer.complete(new Response(Response.NOTFOUND, {}));
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
 * TODO comment
 */
Future<Response> hangupCall(model.Call call){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/hangup';

  List<String> fragments = new List<String>();

  fragments.add('call_id=${call.id}');

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
    ..open(POST, url)
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
        case 204:
          completer.complete(new Response(Response.NOTFOUND, {}));
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
 * TODO Check up on Docs. It says nothing about call_id. 2013-02-27 Thomas P.
 * Sets the call OnHold or park it, if the ask Asterisk.
 */
Future<Response> holdCall(int callId){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/hold';

  List<String> fragments = new List<String>();

  if (callId == null){
    log.critical('Protocol.HoldCall: callId is null');
    throw new Exception();
  }

  fragments.add('call_id=${callId}');

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
    ..open(POST, url)
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
        case 204:
          completer.complete(new Response(Response.NOTFOUND, {}));
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
 * Place a new call to an Agent, a Contact (via contact method, ), an arbitrary PSTn number or a SIP phone.
 *
 * Sends a request to make a new call.
 */
Future<Response> originateCall(int agentId, {int cmId, String pstnNumber, String sip}){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/originate';
  List<String> fragments = new List<String>();

  if (agentId == null){
    log.critical('Protocol.OriginateCall: agentId is null');
    throw new Exception();
  }

  fragments.add('agent_id=${agentId}');

  if (?cmId && cmId != null){
    fragments.add('cm_id=${cmId}');
  }

  if (?pstnNumber && pstnNumber != null){
    fragments.add('pstn_number=${pstnNumber}');
  }

  if (?sip && sip != null && !sip.isEmpty){
    fragments.add('sip=${sip}');
  }

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
    ..open(POST, url)
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
 * Sends a call based on the [callId], if present, to the agent with [AgentId].
 * If no callId is specified, then the next call in line will be dispatched
 * to the agent.
 */
Future<Response> pickupCall(int AgentId, {String callId}){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/pickup';
  List<String> fragments = new List<String>();

  if (AgentId == null) {
    log.critical('Protocol.PickupCall: AgentId is null');
    throw new Exception();
  }

  fragments.add('agent_id=${AgentId}');

  if (callId != null && !callId.isEmpty) {
    fragments.add('call_id=${callId}');
  }

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
    ..open(POST, url)
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
        case 404:
          completer.complete(new Response(Response.NOTFOUND, {}));
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
 * TODO Not implemented in Alice, as fare as i can see. 2013-02-27 Thomas P.
 * Gives the status of a call.
 */
Future<Response> statusCall(int callId){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/state';
  List<String> fragments = new List<String>();

  if (callId == null){
    log.critical('Protocol.StatusCall: callId is null');
    throw new Exception();
  }

  fragments.add('call_id=${callId}');

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
    ..open(POST, url)
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
        case 404:
          completer.complete(new Response(Response.NOTFOUND, {}));
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
 * TODO write better comment.
 * Sends a request to transfer a call.
 */
Future<Response> transferCall(int callId){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/call/transfer';
  List<String> fragments = new List<String>();

  if (callId == null){
    log.critical('Protocol.TransferCall: callId is null');
  }

  fragments.add('source=${callId}');

  String url = _buildUrl(base, path, fragments);
  request = new HttpRequest()
    ..open(POST, url)
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
        case 404:
          completer.complete(new Response(Response.NOTFOUND, {}));
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
