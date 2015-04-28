part of contactserver.router;

void getContact(HttpRequest request) {
  int contactId  = pathParameter(request.uri, 'contact');
  int receptionId = pathParameter(request.uri, 'reception');

  _fetchAndCacheContact(receptionId, contactId, request);
}

Future _fetchAndCacheContact(int receptionId, int contactId, HttpRequest request) {
  return db.getContact(receptionId, contactId).then((Model.Contact contact) {

    if(contact == Model.Contact.nullContact) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      return writeAndClose(request, JSON.encode({}));

    } else {
      return writeAndClose(request, JSON.encode(contact.asMap));
    }
  }).catchError((error) => serverError(request, 'contactserver.router._fetchAndCacheContact() ${error}'));
}
