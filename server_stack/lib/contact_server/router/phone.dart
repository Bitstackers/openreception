part of contactserver.router;

abstract class Phone {

  /**
   *
   */
  static shelf.Response add(shelf.Request request) =>
      new shelf.Response.internalServerError(
          body: 'Not implemented');

  /**
   *
   */
  static shelf.Response remove(shelf.Request request) =>
      new shelf.Response.internalServerError(
          body: 'Not implemented');

  /**
   *
   */
  static shelf.Response update(shelf.Request request) =>
      new shelf.Response.internalServerError(
          body: 'Not implemented');

  /**
   *
   */
  static Future<shelf.Response> ofContact(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _contactDB
        .phones(contactID, receptionID)
        .then((Iterable<Model.PhoneNumber> phones) {
      return new shelf.Response.ok(JSON.encode(phones.toList()));
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }
}