part of router;

void sendMessage(HttpRequest request) {
  extractContent(request).then((String content) {
    Map data;
    
    //Check If the format of the message is valid.
    try {
      data = JSON.decode(content);
      if( !(data.containsKey('to') && data.containsKey('cc') && data.containsKey('bcc') &&
          data['to'] is List && data['cc'] is List && data['bcc'] is List) ) {
        request.response.statusCode = 400;
        String response = JSON.encode(
            {'status'      : 'bad request',
              'description': 'passed message argument is too long, missing or invalid'});
        writeAndClose(request, response);
        return;
      }
    } catch(e) {
      request.response.statusCode = 400;
      String response = JSON.encode(
          {'status'      : 'bad request',
            'description': 'passed message argument is too long, missing or invalid'});
      writeAndClose(request, response);
      return;
    }

    //Check if there are any contacts.
    if(data['to'].length == 0 && 
       data['cc'].length == 0 && 
       data['bcc'].length == 0) {
      request.response.statusCode = 400;
      String response = JSON.encode(
          {'status'      : 'bad request',
            'description': 'no contacts selected'});
      writeAndClose(request, response);
      return;
    }
    
    //Get all the contacts from the database.
    //Check if every one i present
    //Check if there any one that want messages.
  }).catchError((error) => serverError(request, error.toString()));
}
