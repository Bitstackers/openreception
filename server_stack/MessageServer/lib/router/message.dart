part of messageserver.router;

abstract class Message {

  static const String className = '${libraryName}.Message';
  
  /**
   * HTTP Request handler for returning a single message resource.
   */
  static void get(HttpRequest request) {
    int messageID  = pathParameter(request.uri, 'message');
    
    new model.Message.stub(messageID).load()
      .then((model.Message message) => writeAndClose(request, JSON.encode(message)));
  }

  static void list (HttpRequest request) {
    db.Message.list().then ((Map map) { 
        writeAndClose(request, JSON.encode(map));
      }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
  }
  
  /**
   *
   */
  static void send (HttpRequest request) {
    
    final String context = '${className}.send';
    final String token   = request.uri.queryParameters['token'];

    Service.Authentication.userOf(token: token, host: config.authUrl).then((SharedModel.User user) {
      extractContent(request).then((String content) {
        
        try { 
          model.Message message = new model.Message.fromMap(JSON.decode(content))..sender = user;  
          return message.save()
              .then((_) => message.send()
              .then((_) => writeAndClose(request, '{"description" : "Saved and enqueued message." , "id" : ${message.ID} }')));
          

        } catch (error, stackTrace) {
          logger.errorContext('$error : $stackTrace', context);
          clientError(request, '$error : $stackTrace');
        }
        
      }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace : stackTrace));
    }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace : stackTrace));
   }

  
  /**
   *
   */
  static void save (HttpRequest request) {
    
    final String context = '${className}.save';
    final String token   = request.uri.queryParameters['token'];

    Service.Authentication.userOf(token: token, host: config.authUrl).then((SharedModel.User user) {
      extractContent(request).then((String content) {
        model.Message message;
        try { 
          return (new model.Message.fromMap(JSON.decode(content))..sender = user).save()
              .then((_) => writeAndClose(request, '{"status" : "ok"}'));

        } catch (error, stackTrace) {
          logger.errorContext('$error : $stackTrace', context);
          clientError(request, '$error : $stackTrace');
        }
        
      }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace : stackTrace));
    }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace : stackTrace));
  }
}

