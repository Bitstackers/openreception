part of messagedispatcher.router;

void messageDraftSingle(HttpRequest request) {
  //int messageID  = pathParameter(request.uri, 'draft');

  resourceNotFound (request);
}

/**
 * TODO: Reimplement this.
 */
void messageDispatchAll(HttpRequest request) {

  serverError(request, JSON.encode({"error" : "not implemented"}));
}
