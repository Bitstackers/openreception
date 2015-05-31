part of receptionserver.router;

abstract class Reception {

  static final Logger log = new Logger ('$libraryName.Reception');

  static Future<shelf.Response> list(shelf.Request request) {
    return db.Reception.list().then((Iterable<Model.Reception> receptions) {
      return new shelf.Response.ok(JSON.encode(receptions.toList(growable : false)));
    })
    .catchError((error, stackTrace) {
      log.severe (error, stackTrace);
      return new shelf.Response.internalServerError (body : 'db.getreceptionListReturn failed: $error');
    });
  }

  static Future<shelf.Response> get(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return db.Reception.get(receptionID)
      .then((Model.Reception reception) {
        return new shelf.Response.ok (JSON.encode(reception));
      })
      .catchError((error, stackTrace) {
        log.severe (error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'receptionserver.router.getReception: $error');
      });
  }
}