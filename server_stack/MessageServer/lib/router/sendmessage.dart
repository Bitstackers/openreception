part of messageserver.router;

void sendMessage(HttpRequest request) {
  extractContent(request).then((String content) {
    logger.debug(content);
    Map data;
    
    //Check If the format of the message is valid.
    try {
      data = JSON.decode(content);
      if( !(data.containsKey('to') && data.containsKey('cc') && data.containsKey('bcc') &&
          data['to'] is List && data['cc'] is List && data['bcc'] is List) ) {
        request.response.statusCode = 400;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'passed message argument is too long, missing or invalid'});
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
    
    return db.createSendMessage(message, subject, toContactId, takenFrom, takeByAgent, urgent, createdAt).then((Map result) {
      List<Map> recipients = new List<Map>();
      
      (data['to'] as List).map((String con) {
        List<String> split = con.split('@');
        int contactId = int.parse(split[0]);
        int receptionId = int.parse(split[1]);
        recipients.add({'contactId': contactId, 'receptionId':receptionId, 'message_id': result['id'], 'recipient_role': 'to'});
      });
      
      (data['cc'] as List).map((String con) {
        List<String> split = con.split('@');
        int contactId = int.parse(split[0]);
        int receptionId = int.parse(split[1]);
        recipients.add({'contactId': contactId, 'receptionId':receptionId, 'message_id': result['id'], 'recipient_role': 'cc'});
      });
      
      (data['bcc'] as List).map((String con) {
        List<String> split = con.split('@');
        int contactId = int.parse(split[0]);
        int receptionId = int.parse(split[1]);
        recipients.add({'contactId': contactId, 'receptionId':receptionId, 'message_id': result['id'], 'recipient_role': 'bcc'});
      });
      
      return db.addRecipientsToSendMessage(recipients).then((Map result) {
        writeAndClose(request, JSON.encode(result));
      });
    });
    
    /*
     * Jeg står med en JSON med "to, cc, bcc, message"
       
     * Message Queue. skal først have STAM information
         message, subject, to_contact_id, taken_from, taken_by_agent
     * Så skal alle recipients tilføjes til message_queue_recipients
         contact_id, reception_id, message_id, recipient_role
     */
    
    
    //Get all the contacts from the database.
    //Check if every one i present
    //Check if there any one that want messages.
  }).catchError((error) => serverError(request, error.toString()));
}
