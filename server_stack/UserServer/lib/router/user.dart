part of userserver.router;

/**
 * TODO
 */
abstract class User {
  
  static list (HttpRequest request) {
    Model.UserDatabase.userList(db).then((List<Map> userlist) {
      writeAndClose(request, JSON.encode({"users" : userlist}));
    }).catchError((error, stacktrace) {
      serverError(request, error.toString() + " : " + stacktrace.toString());
    });
  }

  static add (HttpRequest request) {
    serverError(request, "Not implemented");
  }

  static remove (HttpRequest request) {
    serverError(request, "Not implemented");
  }

  static update (HttpRequest request) {
    serverError(request, "Not implemented");
  }

  static get (HttpRequest request) {
    serverError(request, "Not implemented");
  }

}