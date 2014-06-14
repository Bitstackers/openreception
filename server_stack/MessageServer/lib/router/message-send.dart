
part of messageserver.router;

void messageSend(HttpRequest request) {
  
  final String context = "messageserver.router.sendMessage";
  
  extractContent(request).then((String content) {
    Map data;
    
    logger.debugContext(content, context);
    
    //Check If the format of the message is valid.
    try {
      data = JSON.decode(content);
      
      if ((data['message'] as String).isEmpty) {
        throw new StateError("Empty messages field not allowed.");
      }
      
      if(!data.containsKey('to') || !(data['to'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "to" is wrong (field is required).'});
        writeAndClose(request, response);
        return null;
      }

      if(data.containsKey('cc') && !(data['cc'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "cc" is wrong.'});
        writeAndClose(request, response);
        return null;
      }
     
      if(data.containsKey('bcc') && !(data['bcc'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "bcc" is wrong.'});
        writeAndClose(request, response);
        return null;
      }
    } catch(e) {
      request.response.statusCode = 400;
      String response = JSON.encode(
          {'status'     : 'bad request',
           'description': 'passed message argument is too long, missing or invalid',
           'error'      : e.toString()});
      writeAndClose(request, response);
      return null;
    }

    //Check if there are any contacts.
    if(data['to'].length == 0) {
      request.response.statusCode = 400;
      String response = JSON.encode(
          {'status'     : 'bad request',
           'description': 'passed message argument "to" does not have any entries.'});
      writeAndClose(request, response);
      return null;
    }
    
    String     message  = data['message'];
    Map      callerInfo = (data.containsKey('caller') ? data['caller'] : {'name' : '', 'company' : ''});
    List          flags = data['flags'];

    model.MessageRecipient messageContext = new model.MessageRecipient.fromMap(data['context']);
    
    return getUserID(request, config.authUrl).then((int userID) {
      return db.createSendMessage(message, messageContext, callerInfo, userID, flags).then((Map result) {
        model.Message message = new model.Message(result['id']);
        
        // Harvest each field for recipients.
        ['bcc','cc','to'].forEach ((String role) {
          print (data[role]);
          logger.debugContext("Adding for role $role", context);
          if (data[role] != null) {
            (data[role] as List).forEach((Map contact) =>  message.addRecipient(new model.MessageRecipient.fromMap(contact, role)));
          }
        });
        
        return db.addRecipientsToSendMessage(message.sqlRecipients()).then((Map result) {
          return db.enqueue(message).then((queueSize) {
            logger.debugContext("inserted $queueSize elements in queue.", context);
            writeAndClose(request, JSON.encode(result));
            
            logger.debugContext("inserted $queueSize elements in queue.", context); 
            Service.Notification.broadcast({'event' : 'messageSend', 'message_id' : message.ID}, config.notificationServer, config.serverToken);
          });
        });
      });
    });
  });//.catchError((error) => serverError(request, error.toString()));
}

Future<int> getUserID (HttpRequest request, Uri authUrl) {
    try {
      if(request.uri.queryParameters.containsKey('token')) {      
        String path = 'token/${request.uri.queryParameters['token']}';
        Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: path);
        print(url);
        return http.get(url).then((response) {
          if (response.statusCode == 200) {
            logger.debugContext (response.body, "common.AH_HTTPRequest.getUserID()");
            return JSON.decode(response.body)['id'];
          } else {
            return 0;
          }
        }).catchError((error) {
          return 0;
        });
        
      } else {
        return new Future.value(false);
      }
    } catch (e) {
      logger.critical('utilities.httpserver.auth() ${e} authUrl: "${authUrl}"');
    }
}

