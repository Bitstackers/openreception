part of messageserver.router;

void sendMessage(HttpRequest request) {
  extractContent(request).then((String content) {
    logger.debug(content);
    Map data;
    
    //Check If the format of the message is valid.
    try {
      data = JSON.decode(content);
      if(!data.containsKey('to') || !(data['to'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "to" is wrong'});
        writeAndClose(request, response);
        return null;
      }

      if(!data.containsKey('cc') || !(data['cc'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "cc" is wrong'});
        writeAndClose(request, response);
        return null;
      }
     
      if(!data.containsKey('bcc') || !(data['bcc'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "bcc" is wrong'});
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
    
    //Make a check if every field are present
    
    String message     = data['message'];
    String subject     = data['subject'];
    int toContactId    = data['toContactId'];
    String takenFrom   = data['takenFrom'];
    int takeByAgent    = data['takeByAgent'];
    bool urgent        = data['urgent'];
    DateTime createdAt = DateTime.parse(data['createdAt']);
    
    
    
    return tempSMTP(message, subject, ['tp@adaheads.com']).then((_) {
      writeAndClose(request, JSON.encode({'status': 'Success'}));
    });
    
//    return db.createSendMessage(message, subject, toContactId, takenFrom, takeByAgent, urgent, createdAt).then((Map result) {
//      List<Map> recipients = new List<Map>();
//      
//      (data['to'] as List).map((String con) {
//        List<String> split = con.split('@');
//        int contactId = int.parse(split[0]);
//        int receptionId = int.parse(split[1]);
//        recipients.add({'contactId': contactId, 'receptionId':receptionId, 'message_id': result['id'], 'recipient_role': 'to'});
//      });
//      
//      (data['cc'] as List).map((String con) {
//        List<String> split = con.split('@');
//        int contactId = int.parse(split[0]);
//        int receptionId = int.parse(split[1]);
//        recipients.add({'contactId': contactId, 'receptionId':receptionId, 'message_id': result['id'], 'recipient_role': 'cc'});
//      });
//      
//      (data['bcc'] as List).map((String con) {
//        List<String> split = con.split('@');
//        int contactId = int.parse(split[0]);
//        int receptionId = int.parse(split[1]);
//        recipients.add({'contactId': contactId, 'receptionId':receptionId, 'message_id': result['id'], 'recipient_role': 'bcc'});
//      });
//      
//      return db.addRecipientsToSendMessage(recipients).then((Map result) {
//        writeAndClose(request, JSON.encode(result));
//      });
//    });
       
  }).catchError((error) => serverError(request, error.toString()));
}

Future tempSMTP(String message, String subject, List<String> recipients) {
  // If you want to use an arbitrary SMTP server, go with `new SmtpOptions()`.
  // This class below is just for convenience. There are more similar classes available.
  var options = new GmailSmtpOptions()
    ..username = config.emailUsername
    ..password = config.emailPassword; // Note: if you have Google's "app specific passwords" enabled,
                                        // you need to use one of those here.
  
  // Create our email transport.
  var emailTransport = new SmtpTransport(options);
  
  // Create our mail/envelope.
  var envelope = new Envelope()
    ..fromName = 'MyCompany'
    ..recipients.addAll(recipients)
    ..subject = subject
    ..text = message;

  // Email it.
  return emailTransport.send(envelope)
    .then((success) => log('Email sent! $success'))
    .catchError((e) => logger.error('Error occured when sending mail: $e'));
}
