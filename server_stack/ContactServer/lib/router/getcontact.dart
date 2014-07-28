part of contactserver.router;

void getContact(HttpRequest request) {
  int contactId  = pathParameter(request.uri, 'contact');
  int receptionId = pathParameter(request.uri, 'reception');

  cache.loadContact(receptionId, contactId).then((String reception) {
    writeAndClose(request, reception);

  }).catchError((_) {
    return _fetchAndCacheContact(receptionId, contactId, request);
  });
}

Future _fetchAndCacheContact(int receptionId, int contactId, HttpRequest request) {
  return db.getContact(receptionId, contactId).then((Map value) {
    String contact = JSON.encode(value);

    if(value.isEmpty) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      writeAndClose(request, contact);

    } else {
      writeAndClose(request, contact);
      return cache.saveContact(receptionId, contactId, contact)
        .catchError((error) {
          log('contactserver.router.getContact $error');
        });
    }
  }).catchError((error) => serverError(request, 'contactserver.router._fetchAndCacheContact() ${error}'));
}
