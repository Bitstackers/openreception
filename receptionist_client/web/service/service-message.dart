part of service;

abstract class Message {
  
  static final String className = '${libraryName}.Message'; 
  
  static Future<Response<Map>> send(model.Message message, [Uri host]) {
    
    final String context = '${className}.send';
    
    if (host == null) {
      host = configuration.messageBaseUrl;
    };
    
    final String                   base       = configuration.messageBaseUrl.toString();
    final Completer<Response<Map>> completer  = new Completer<Response<Map>>();
    final List<String>             fragments = new List<String>();
    final String                   path       = '/message/send';

    /* Attach the cc recipients - only if there are any. 
    if (cc != null) {
      payload ['cc'] = cc.map((v) => v.toString()).toList();
    }

    /* Same thing goes for the bcc recipients.*/ 
    if (bcc != null) {
      payload ['bcc'] = bcc.map((v) => v.toString()).toList();
    }
    */
    
    /* Assemble the initial content for the message. */
    Map payload = message.toMap;

    /* 
     * Now we are ready to send the request to the server. 
     */
    
    HttpRequest                    request;
    String                         url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);
    
    log.debugContext('url: ${url} - payload: ${payload}', context);

    request = new HttpRequest()
    ..open(POST, url)
    ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = JSON.decode(request.responseText);
          if (data != null) {
            completer.complete(new Response<Map>(Response.OK, data));
          } else {
            completer.complete(new Response<Map>(Response.ERROR, data));
          }
          break;

        default:
          completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
      }
    })
    ..onError.listen((e) {
      print(url);
      completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
    })
    ..send(JSON.encode(payload));

    return completer.future;
  }
}

String _buildUrl(String base, String path, [List<String> fragments]) {
  assert(base != null);
  assert(path != null);

  final StringBuffer buffer  = new StringBuffer();
  final String       url = '${base}${path}';

  if (fragments != null && !fragments.isEmpty) {
    buffer.write('?${fragments.first}');
    fragments.skip(1).forEach((fragment) => buffer.write('&${fragment}'));
  }

  return '${url}${buffer.toString()}';
}
