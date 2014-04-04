part of messageserver.router;

void messageDraftDelete(HttpRequest request) {
  int draftID  = pathParameter(request.uri, 'draft');
  
  db.messageDraftDelete(draftID).then((value) {
    print ("hat");
    writeAndClose(request,"{}" );
    print ("hat");
  }).catchError((error) => serverError(request, error.toString()));
}

