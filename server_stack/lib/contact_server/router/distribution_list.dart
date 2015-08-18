part of contactserver.router;

abstract class DistributionList {

  /**
   *
   */
  static Future<shelf.Response> addRecipient(shelf.Request request) {
    int cid = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int rid = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString()
      .then(JSON.decode)
      .then(Model.MessageRecipient.decode)
      .then((Model.MessageRecipient rcp) =>
          _dlistDB.addRecipient(rid, cid, rcp)
          .then(JSON.encode)
          .then((String encodedString) =>
              new shelf.Response.ok(encodedString)))
      .catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  static Future<shelf.Response> removeRecipient(shelf.Request request) {
    int did = int.parse(shelf_route.getPathParameter(request, 'did'));

    return _dlistDB.removeRecipient(did).then((_) =>
        new shelf.Response.ok(JSON.encode(const {})))
      .catchError((error, stacktrace) {
        log.severe(error, stacktrace);
        new shelf.Response.internalServerError(body: '${error}');
    });
  }

  /**
   *
   */
  static Future<Iterable<shelf.Response>> ofContact(shelf.Request request) {
    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return _dlistDB
        .list(receptionID, contactID)
        .then((Model.DistributionList dlist) {
      return new shelf.Response.ok(JSON.encode(dlist));
    }).catchError((error, stacktrace) {
      log.severe(error, stacktrace);
      new shelf.Response.internalServerError(body: '${error}');
    });
  }
}