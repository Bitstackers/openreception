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
 * Get a list of every active call.
 *
 * Completes with:
 *  On success: [Response] object with status OK
 *  On error  : [Response] object with status ERROR or CRITICALERROR
 */
Future<Response<Map>> callList() {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/list';
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

        case 204:
          completer.complete(new Response<Map>(Response.OK, null));
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
 * Get a list of waiting calls.
 */
Future<Response<Map>> callQueue() {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/queue';
  HttpRequest                    request;
  String                         url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);
      
  request = new HttpRequest()
    ..open(GET, url)
    ..onLoad.listen((_) {
//      Map data = {'calls': [
//                        {'assigned_to': '',
//                          'organization_id': 1,
//                          'id': 'callid_1',
//                          'arrival_time': '1382099801'},
//
//                         {'assigned_to': '',
//                          'organization_id': 2,
//                          'id': 'callid_2',
//                          'arrival_time': '1382099831'},
//
//                         {'assigned_to': '',
//                          'organization_id': 1,
//                          'id': 'callid_3',
//                          'arrival_time': '1382099821'}
//
//                            ]};
//      Map data = new Map();
//      List calls = new List();
//      calls.add({'id':'31','arrival_time':'${(new DateTime.now().subtract(new Duration(seconds:  3)).millisecondsSinceEpoch~/1000)}', 'organization_id': 1, 'assigned_to': 'Thomas'});
//      calls.add({'id':'27','arrival_time':'${(new DateTime.now().subtract(new Duration(seconds: 15)).millisecondsSinceEpoch~/1000)}', 'organization_id': 1, 'assigned_to': 'Thomas'});
//      calls.add({'id':'11','arrival_time':'${(new DateTime.now().subtract(new Duration(seconds: 37)).millisecondsSinceEpoch~/1000)}', 'organization_id': 1, 'assigned_to': 'Thomas'});
//      data['calls'] = calls;
//      log.debug('protocol.call.dart callQueue is sending out fake data.');

//      completer.complete(new Response<Map>(Response.OK, data));
//      return;

      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 204:
          completer.complete(new Response<Map>(Response.NOTFOUND, null));
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

Future<Response<model.CallList>> callLocalList(int agentId) {
  final String                               base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<model.CallList>>  completer = new Completer<Response<model.CallList>>();
  final List<String>                         fragments = new List<String>();
  final String                               path      = '/call/localList';
  HttpRequest                                request;
  String                                     url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

//Dummy Data
//  Map dummyData = new Map();
//  List calls = new List();
//  calls.add({'id':'40','arrival_time':'${(new DateTime.now().millisecondsSinceEpoch~/1000)}', 'organization_id': 1, 'assigned_to': 'Thomas'});
//  calls.add({'id':'55','arrival_time':'${(new DateTime.now().subtract(new Duration(seconds: 13)).millisecondsSinceEpoch~/1000)}', 'organization_id': 1, 'assigned_to': 'Thomas'});
//  calls.add({'id':'63','arrival_time':'${(new DateTime.now().subtract(new Duration(seconds: 37)).millisecondsSinceEpoch~/1000)}', 'organization_id': 1, 'assigned_to': 'Thomas'});
//  dummyData['calls'] = calls;
//  model.CallList data = new model.CallList.fromJson(dummyData, 'calls');
//  completer.complete(new Response<model.CallList>(Response.OK, data));

  request = new HttpRequest()
    ..open(POST, url)
    ..onLoad.listen((_) {
      Map data = _parseJson(request.responseText);
      model.CallList list = new model.CallList.fromJson(data, 'calls');
      completer.complete(new Response<model.CallList>(Response.OK, list));
    })
    ..onError.listen((e) {
      _logError(request, url);
      completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
    })
    ..send();

  return completer.future;
}

/**
 * Hangup [call].
 */
Future<Response<Map>> hangupCall(model.Call call) {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/hangup';
  HttpRequest                    request;
  String                         url;

  fragments.add('token=${configuration.token}');
  fragments.add('call_id=${call.id}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(POST, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 404:
          completer.complete(new Response<Map>(Response.NOTFOUND, null));
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
Future<Response<Map>> originateCall(String extension) {
  assert(extension != null);
  assert(extension.isNotEmpty);

  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/originate';
  HttpRequest                    request;
  String                         url;

  if (extension != null && extension.isNotEmpty){
    fragments.add('extension=${extension}');
  }
  fragments.add('token=${configuration.token}');
  
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(POST, url)
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
 * Park [call].
 * TODO Check up on Docs. It says nothing about call_id. 2013-02-27 Thomas P.
 */
Future<Response<Map>> parkCall(model.Call call) {
  assert(call != null);

  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/park';
  HttpRequest                    request;
  String                         url;

  fragments.add('call_id=${call.id}');
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(POST, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 404:
          completer.complete(new Response<Map>(Response.NOTFOUND, null));
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
Future<Response<Map>> pickupCall({model.Call call}) {
  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/pickup';
  HttpRequest                    request;
  String                         url;

  if (call != null && call.id != null) {
    fragments.add('call_id=${call.id}');
  }
  fragments.add('token=${configuration.token}');
  
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(POST, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 204:
          completer.complete(new Response<Map>(Response.NOTFOUND, null));
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
 * TODO Not implemented in Alice, as far as i can see. 2013-02-27 Thomas P.
 * Gives the status of a call.
 */
Future<Response<Map>> statusCall(model.Call call) {
  assert(call != null);

  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/state';
  HttpRequest                    request;
  String                         url;

  fragments.add('call_id=${call.id}');
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(POST, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 404:
          completer.complete(new Response<Map>(Response.NOTFOUND, {}));
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
 * Sends a request to transfer a call.
 */
Future<Response<Map>> transferCall(String source, String destination) {
  assert(source != null);
  assert(source != model.nullCall);

  final String                   base      = configuration.callFlowBaseUrl.toString();
  final Completer<Response<Map>> completer = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path      = '/call/transfer';
  HttpRequest                    request;
  String                         url;

  fragments.add('source=${source}');
  fragments.add('destination=${destination}');
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(POST, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 404:
          completer.complete(new Response<Map>(Response.NOTFOUND, null));
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
