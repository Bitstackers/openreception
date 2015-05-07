part of receptionserver.router;

abstract class Reception {

  static final Logger log = new Logger ('$libraryName.Reception');

  static Future list(HttpRequest request) {
    return db.Reception.list().then((Iterable<Model.Reception> receptions) {
      writeAndClose(request, JSON.encode(receptions.toList(growable : false)));
    })
    .catchError((error, stackTrace) {
      log.severe (error, stackTrace);
      serverError(request,'db.getreceptionListReturn failed: $error');
    });
  }
}