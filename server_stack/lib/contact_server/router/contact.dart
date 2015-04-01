part of contactserver.router;

abstract class Contact{

  static final Logger log = new Logger ('$libraryName.Contact');

  static Future<bool> exists({int contactID, int receptionID}) =>
      db.getContact(receptionID, contactID).then((Model.Contact contact) =>
          contact != Model.Contact.nullContact);

  /**
   * Retrives a single contact based on receptionID and contactID.
   */
  static Future<Model.Contact> get (HttpRequest request) {
    int contactId  = pathParameter(request.uri, 'contact');
    int receptionId = pathParameter(request.uri, 'reception');

    return db.getContact(receptionId, contactId).then((Model.Contact contact) {

      if(contact == Model.Contact.nullContact) {
        return notFound(request,
            {'description' : 'no contact $contactId@$receptionId'});

      } else {
        return writeAndClose(request, JSON.encode(contact.asMap));
      }
    }).catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        serverError(request, 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }



}