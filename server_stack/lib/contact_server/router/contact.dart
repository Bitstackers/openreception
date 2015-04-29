part of contactserver.router;

abstract class Contact{

  static final Logger log = new Logger ('$libraryName.Contact');

  static Future<bool> exists({int contactID, int receptionID}) =>
      db.Contact.get(receptionID, contactID).then((Model.Contact contact) =>
          contact != Model.Contact.nullContact);

  /**
   * Retrives a single contact based on receptionID and contactID.
   */
  static Future get (shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return db.Contact.get(receptionID, contactID).then((Model.Contact contact) {

      if(contact == Model.Contact.nullContact) {
        return new shelf.Response.notFound({'description' : 'no contact $contactID@$receptionID'});

      } else {
        return new shelf.Response.ok(JSON.encode(contact.asMap));
      }
    }).catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(body : 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   *
   */
  static Future endpoints (shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return db.Contact.endpoints(contactID, receptionID)
      .then((Iterable<Model.MessageEndpoint> endpoints) {
        return new shelf.Response.ok(JSON.encode(endpoints.toList()));
    }).catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(body : 'contactserver.router._fetchAndCacheContact() ${error}');
    });
  }

  /**
   *
   */
  static Future phones (shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return db.Contact.phones(contactID, receptionID)
      .then((Iterable<Map> phones) {
        return new shelf.Response.ok(JSON.encode(phones.toList()));
    }).catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(
            body : '${error}');
    });
  }

  /**
   * Gives a lists of every contact in an reception.
   */
  static Future list(shelf.Request request) {
    var rid = shelf_route.getPathParameter(request, 'rid');
    print (rid);
    int receptionID = int.parse(rid);

    return db.Contact.list(receptionID)
      .then((Iterable<Model.Contact> contacts) {
      return new shelf.Response.ok(JSON.encode(contacts.toList()));
    }).catchError((error) {
    }).catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(
            body : '${error}');
    });
  }

}