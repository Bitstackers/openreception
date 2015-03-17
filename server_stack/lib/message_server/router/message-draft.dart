part of messageserver.router;

abstract class MessageDraft {

  /**
   * HTTP response handler for message/create
   */
  static void create(HttpRequest request) {
    int userID = 10;

    extractContent(request).then((String content) {
      Database.MessageDraft.create(userID, JSON.decode(content), connection).then((value) {
        writeAndClose(request, JSON.encode(value));
      });
    }).catchError((error) => serverError(request, error.runtimeType +  error.toString()));
  }

  static void update(HttpRequest request) {
    int draftID  = pathParameter(request.uri, 'draft');

    extractContent(request).then((String content) {
      Map data = JSON.decode(content);
      Database.MessageDraft.update(draftID, content, connection).then((value) {
        writeAndClose(request, JSON.encode(value));
      });
    }).catchError((error, stackTrace) => _onException(request, error, stackTrace));
  }

  static void get(HttpRequest request) {
    int messageID  = pathParameter(request.uri, 'draft');

    Database.MessageDraft.get(messageID, connection).then((Map value) {
        writeAndClose(request, JSON.encode(value));
      }).catchError((error, stackTrace) => _onException(request, error, stackTrace));
  }

  static void _onException (HttpRequest request, error, StackTrace stackTrace) {

    if (error is Storage.NotFound) {
      notFound (request, {'description' :'not found'});
    } else {
      serverErrorTrace(request, error, stackTrace: stackTrace);
    }
  }

  static void list(HttpRequest request) {
    Database.MessageDraft.list(0, 100, connection).then((Map value) {
      writeAndClose(request, JSON.encode(value));
    }).catchError((error) => serverError(request, error.toString()));
  }

  static void delete(HttpRequest request) {
    int draftID  = pathParameter(request.uri, 'draft');

    Database.MessageDraft.delete(draftID, connection).then((value) {
      writeAndClose(request,'{ "status" : "successfully deleted draft with ID $draftID" }' );
    }).catchError((error,stackTrace) => serverErrorTrace(request, error, stackTrace : stackTrace));
  }
}