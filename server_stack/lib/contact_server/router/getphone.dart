part of contactserver.router;

void getPhone(HttpRequest request) {
  int contactId = pathParameter(request.uri, 'contact');
  int receptionId = pathParameter(request.uri, 'reception');
  int phoneId = pathParameter(request.uri, 'phone');
  
  db.getPhone(contactId, receptionId,phoneId).then((Map value) {
    String phone = JSON.encode(value);
    
    if(value.isEmpty) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
    }

    writeAndClose(request, phone);
    
  }).catchError((error) => serverError(request, error.toString()));
}