part of contactserver.router;

void getPhone(HttpRequest request) {
  int phoneId = int.parse(request.uri.pathSegments.elementAt(1));  
  
  db.getPhone(phoneId).then((Map value) {
    String phone = JSON.encode(value);
    
    if(value.isEmpty) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
    }

    writeAndClose(request, phone);
    
  }).catchError((error) => serverError(request, error.toString()));
}