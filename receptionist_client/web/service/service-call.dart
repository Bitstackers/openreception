part of service;

abstract class Call {
  
  /**
   * Fetches a list of currently queued calls from the Server.
   */
  Future<model.CallList> queue() {

    const String context = '${libraryName}.queue';
    
    final String                    base      = configuration.callFlowBaseUrl.toString();
    final Completer<model.CallList> completer = new Completer<model.CallList>();
    final List<String>              fragments = new List<String>();
    final String                    path      = '/call/queue';
    HttpRequest                     request;
    String                          url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);
        
    request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((_) {
        switch(request.status) {
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
    
    const String context = '${libraryName}.list';

    final String                   base      = configuration.callFlowBaseUrl.toString();
    final Completer<model.CallList> completer = new Completer<model.CallList>();
    final List<String>             fragments = new List<String>();
    final String                   path      = '/call/list';
    HttpRequest                    request;
    String                         url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);
      
    request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((_) {
      switch (request.status) {
        case 200:
          completer.complete(new model.Call.fromJson(JSON.decode(request.responseText)));
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
   * Sends a call based on the [callId], if present, to the agent with [AgentId].
   * If no callId is specified, then the next call in line will be dispatched
   * to the agent.
   */
  static Future<model.Call> pickup(model.Call call) {
    
    const String context = '${libraryName}.pickup';
    
    log.debugContext('Requesting to pickup ${call == null ? 'unspecifed call':'call with ID ${call.ID}'}' , context);
    
    final String                   base      = configuration.callFlowBaseUrl.toString();
    final Completer<model.Call> completer = new Completer<model.Call>();
    final List<String>             fragments = new List<String>();
    final String                   path      = '/call/pickup';
    HttpRequest                    request;
    String                         url;

    if (call != null && call.ID != null) {
      fragments.add('call_id=${call.ID}');
    }
    fragments.add('token=${configuration.token}');
    
    url = _buildUrl(base, path, fragments);
    
    request = new HttpRequest()
      ..open(POST, url)
      ..onLoad.listen((_) {
      switch (request.status) {
        case 200:
          
          completer.complete(new model.Call.fromJson(JSON.decode(request.responseText)));
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
}