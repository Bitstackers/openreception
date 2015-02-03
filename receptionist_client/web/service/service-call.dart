/*                     This file is part of Bob
                   Copyright (C) 2014-, AdaHeads K/S

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

abstract class Call {

  static const className = '${libraryName}.Call';

  /**
   * Fetches a userStates of all users
   */
  static Future<Iterable<model.UserStatus>> userStateList() {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<Iterable<model.UserStatus>> completer = new Completer<Iterable<model.UserStatus>>();
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
              completer.complete(responseList.map((Map element) => new model.UserStatus.fromMap(element)));
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
  static Future<model.UserStatus> userState(int userID) {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.UserStatus> completer = new Completer<model.UserStatus>();
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
              completer.complete(new model.UserStatus.fromMap(JSON.decode(request.responseText)));
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
  static Future<model.UserStatus> markUserStateIdle(int userID) {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.UserStatus> completer = new Completer<model.UserStatus>();
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
              completer.complete(new model.UserStatus.fromMap(JSON.decode(request.responseText)));
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
  static Future<model.UserStatus> markUserStatePaused(int userID) {

    const String context = '${className}.userState';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.UserStatus> completer = new Completer<model.UserStatus>();
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
              completer.complete(new model.UserStatus.fromMap(JSON.decode(request.responseText)));
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
  static Future<model.CallList> queue() {

    const String context = '${className}.queue';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.CallList> completer = new Completer<model.CallList>();
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
              completer.complete(new model.CallList.fromJson(JSON.decode(request.responseText), 'calls'));
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
  static Future<model.CallList> list() {

    const String context = '${className}.list';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.CallList> completer = new Completer<model.CallList>();
    final List<String> fragments = new List<String>();
    final String path = '/call/list';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete(new model.CallList.fromJson(JSON.decode(request.responseText), 'calls'));
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


  static Future<model.Call> next() {
    return pickup(null);
  }
  /**
   * Park [call].
   */
  static Future<model.Call> park(model.Call call) {

    const String context = '${className}.park';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.Call> completer = new Completer<model.Call>();
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
  static Future<model.Call> pickup(model.Call call) {

    const String context = '${className}.pickup';

    log.debugContext('Requesting to pickup ${call == null ? 'unspecifed call':'call with ID ${call.ID}'}', context);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.Call> completer = new Completer<model.Call>();
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
              completer.complete(new model.Call.fromMap(JSON.decode(request.responseText)));
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
  static Future<model.OriginationRequest> originate(int contactID, int receptionID, String extension) {

    const String context = '${className}.originate';

    assert(extension != null && extension.isNotEmpty);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.OriginationRequest> completer = new Completer<model.OriginationRequest>();
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
              completer.complete(new model.OriginationRequest(JSON.decode(request.responseText)['call']['id']));
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

  static Future<model.Call> hangup(model.Call call) {

    const String context = '${className}.hangup';

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.Call> completer = new Completer<model.Call>();
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
  static Future<model.Call> get(model.Call call) {

    const String context = '${className}.get';

    assert(call != null);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.Call> completer = new Completer<model.Call>();
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
              completer.complete(new model.Call.fromMap(JSON.decode(request.responseText)));
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
  static Future<model.Call> transfer(model.Call source, model.Call destination) {

    const String context = '${className}.transfer';

    assert(source != null && source != model.nullCall);
    assert(destination != null && destination != model.nullCall);

    final String base = configuration.callFlowBaseUrl.toString();
    final Completer<model.Call> completer = new Completer<model.Call>();
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
  Future<model.CallList> listParked(model.User ofUser) {
    const String context = '${className}.listParked';

    throw new StateError('Not implemented!');
  }
}

