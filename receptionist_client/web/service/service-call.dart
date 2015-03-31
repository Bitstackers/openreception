/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of service;

class Call {

  static const className = '${libraryName}.Call';

  static ORService.CallFlowControl _service = null;

  static Call _instance;

  static Call get instance {
    if (_instance == null) {
      _instance = new Call();
    }

    return _instance;
  }

  Call () {
    _service = new ORService.CallFlowControl
        (configuration.callFlowBaseUrl,
         configuration.token,
         new ORServiceHTML.Client());
  }

  Future<Iterable<Model.Call>> listCalls() {
    return _service.callListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.Call.fromMap(map)));
  }

  /**
   * Fetches a userStates of all users
   */
  static Future<Iterable<Model.UserStatus>> userStateList() {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Iterable<Model.UserStatus>> completer = new Completer<Iterable<Model.UserStatus>>();
    final List<String> fragments = new List<String>();
    final String path = '/userstate';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              List<Map> responseList = JSON.decode(request.responseText);
              completer.complete(responseList.map((Map element) => new Model.UserStatus.fromMap(element)));
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * Fetches a userState associated with userID.
   */
  static Future<Model.UserStatus> userState(int userID) {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.UserStatus> completer = new Completer<Model.UserStatus>();
    final List<String> fragments = new List<String>();
    final String path = '/userstate/${userID}';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.UserStatus.fromMap(JSON.decode(request.responseText)));
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * Updates userState associated with userID to Idle state.
   */
  static Future<Model.UserStatus> markUserStateIdle(int userID) {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.UserStatus> completer = new Completer<Model.UserStatus>();
    final List<String> fragments = new List<String>();
    final String path = '/userstate/${userID}/idle';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.UserStatus.fromMap(JSON.decode(request.responseText)));
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * Updates userState associated with userID to Paused state.
   */
  static Future<Model.UserStatus> markUserStatePaused(int userID) {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.UserStatus> completer = new Completer<Model.UserStatus>();
    final List<String> fragments = new List<String>();
    final String path = '/userstate/${userID}/paused';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.UserStatus.fromMap(JSON.decode(request.responseText)));
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * Fetches a list of currently queued calls from the Server.
   */
  static Future<Model.CallList> queue() {

    const String context = '${className}.queue';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.CallList> completer = new Completer<Model.CallList>();
    final List<String> fragments = new List<String>();
    final String path = '/call/queue';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.CallList.fromList(JSON.decode(request.responseText)));
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }


  /**
   * Get a list of every active call.
   *
   * Completes with:
   *  On success: [Response] object with status OK
   *  On error  : [Response] object with status ERROR or CRITICALERROR
   */
  static Future<Model.CallList> list() {

    const String context = '${className}.list';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.CallList> completer = new Completer<Model.CallList>();
    final List<String> fragments = new List<String>();
    final String path = '/call';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.CallList.fromList(JSON.decode(request.responseText)));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }


  static Future<Model.Call> next() {
    return pickup(null);
  }
  /**
   * Park [call].
   */
  static Future<Model.Call> park(Model.Call call) {

    const String context = '${className}.park';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.Call> completer = new Completer<Model.Call>();
    final List<String> fragments = new List<String>();
    final String path = '/call/${call.ID}/park';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(call);
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * Sends a call based on the [callId], if present, to the agent with [AgentId].
   * If no callId is specified, then the next call in line will be dispatched
   * to the agent.
   */
  static Future<Model.Call> pickup(Model.Call call) {

    const String context = '${className}.pickup';

    log.debugContext('Requesting to pickup ${call == null ? 'unspecifed call':'call with ID ${call.ID}'}', context);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.Call> completer = new Completer<Model.Call>();
    final List<String> fragments = new List<String>();
    final String path = '/call/${(call != null && call.ID != null) ? call.ID+"/" : ''}pickup';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.Call.fromMap(JSON.decode(request.responseText)));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }


  /**
   * Place a new call to an arbitrary PSTN number or a SIP phone.
   *
   * Sends a request to make a new call.
   */
  static Future<Model.OriginationRequest> originate(int contactID, int receptionID, String extension) {

    const String context = '${className}.originate';

    assert(extension != null && extension.isNotEmpty);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.OriginationRequest> completer = new Completer<Model.OriginationRequest>();
    final List<String> fragments = new List<String>();
    final String path = '/call/originate/${extension}/reception/${receptionID}${contactID != null ? '/contact/${contactID}' : ''}';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');

    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.OriginationRequest(JSON.decode(request.responseText)['call']['id']));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }
  /**
   * Hangup [call].
   */

  static Future<Model.Call> hangup(Model.Call call) {

    const String context = '${className}.hangup';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.Call> completer = new Completer<Model.Call>();
    final List<String> fragments = new List<String>();
    final String path = '/call/${call.ID}/hangup';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    fragments.add('call_id=${call.ID}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(call);
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * TODO Not implemented in Alice, as far as i can see. 2013-02-27 Thomas P.
   * Gives the status of a call.
   */
  static Future<Model.Call> get(Model.Call call) {

    const String context = '${className}.get';

    assert(call != null);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.Call> completer = new Completer<Model.Call>();
    final List<String> fragments = new List<String>();
    final String path = '/call/${call.ID}';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new Model.Call.fromMap(JSON.decode(request.responseText)));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
 * Sends a request to transfer a call.
 */
  static Future<Model.Call> transfer(Model.Call source, Model.Call destination) {

    const String context = '${className}.transfer';

    assert(source != null && source != Model.noCall);
    assert(destination != null && destination != Model.noCall);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Model.Call> completer = new Completer<Model.Call>();
    final List<String> fragments = new List<String>();
    final String path = '/call/${source.ID}/transfer/${destination.ID}';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(POST, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(source);
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }
  Future<Model.CallList> listParked(Model.User ofUser) {
//    const String context = '${className}.listParked';

    throw new StateError('Not implemented!');
  }
}

