part of service;

abstract class Peer {
  
  /**
   * Fetches a list of currently known peers from the Server.
   */
  static Future<model.PeerList> list() {
    
    const String context = '${libraryName}.list';

    final String                   base      = "http://localhost:4242";
    final Completer<model.PeerList> completer = new Completer<model.PeerList>();
    final List<String>             fragments = new List<String>();
    final String                   path      = '/debug/peer/list';
    HttpRequest                    request;
    String                         url;
    
    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);
        
    request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((_) {
        switch(request.status) {
          case 200:
            completer.complete(new model.PeerList.fromList(JSON.decode(request.responseText)['peers']));
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