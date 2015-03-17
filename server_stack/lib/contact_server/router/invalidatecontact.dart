part of contactserver.router;

void invalidateReception(HttpRequest request) {
  int receptionId = pathParameter(request.uri, 'reception');
  int contactId = pathParameter(request.uri, 'contact');

  cache.removeContact(receptionId, contactId).whenComplete(() {
    writeAndClose(request, JSON.encode({}));
  });
}
