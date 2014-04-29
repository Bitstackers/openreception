part of messagedispatcher.router;

void messageQueueList(HttpRequest request) {
  db.messageQueueList().then((List queuedMessages) {
    writeAndClose(request, JSON.encode({'queue' : queuedMessages}));
  }).catchError((error) => serverError(request, error.toString()));
}

