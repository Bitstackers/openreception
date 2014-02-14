part of contactserver.router;

void getContactsPhone(HttpRequest request) {
  int contactId = pathParameter(request.uri, 'contact');
  int receptionId = pathParameter(request.uri, 'reception');
  
  db.getContactsPhones(receptionId, contactId).then((Map value) {
    String phone = JSON.encode(value);
    
    if(value.isEmpty) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
    }

    writeAndClose(request, phone);
    
  }).catchError((error) => serverError(request, 'contactserver.router.getContactsPhone() Url ${request.uri} threw ${error}'));
}