part of contactserver.router;

void getContact(HttpRequest request) {
  int contactId  = pathParameter(request.uri, 'contact');
  int orgId = pathParameter(request.uri, 'organization');
  
  cache.loadContact(orgId, contactId).then((String org) {
    writeAndClose(request, org);
      
  }).catchError((_) {
    _fetchAndCacheContact(orgId, contactId, request);
  });
}

void _fetchAndCacheContact(int orgId, int contactId, HttpRequest request) {
  db.getContact(orgId, contactId).then((Map value) {
    String contact = JSON.encode(value);
    
    if(value.isEmpty) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      writeAndClose(request, contact);
      
    } else {
      writeAndClose(request, contact);
      return cache.saveContact(orgId, contactId, contact)
        .catchError((error) {
          log('contactserver.router.getContact $error');
        });
    }
  }).catchError((error) => serverError(request, error.toString()));
}
