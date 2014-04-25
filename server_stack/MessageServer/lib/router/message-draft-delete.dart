part of messageserver.router;

void messageDraftDelete(HttpRequest request) {
  int draftID  = pathParameter(request.uri, 'draft');
  
  db.messageDraftDelete(draftID).then((value) {
    writeAndClose(request,'{ "status" : "successfully deleted draft with ID $draftID" }' );
  }).catchError((error) => serverError(request, error.toString()));
}

