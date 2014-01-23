part of contactserver.router;

void getPhone(HttpRequest request) {
  int phoneId = pathParameter(request.uri, 'phone');
  
  db.getPhone(phoneId).then((Map value) {
    String phone = JSON.encode(value);
    
    if(value.isEmpty) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
    }

    writeAndClose(request, phone);
    
  }).catchError((error) => serverError(request, error.toString()));
}