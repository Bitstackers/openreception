part of contactserver.router;

/**
 * Gives a lists of every contact in an reception.
 */
void getContactList(HttpRequest request) {
  int receptionId = pathParameter(request.uri, 'reception');

  db.getReceptionContactList(receptionId).then((List<Model.Contact> contacts) {
    writeAndClose(request, JSON.encode(contacts));
  }).catchError((error) => serverError(request, 'getContactList. db.getReceptionContactList returned error: $error'));
}
