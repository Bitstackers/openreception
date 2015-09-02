part of messagedispatcher.router;

void messageQueueList(HttpRequest request) {
  messageQueueStore.list(maxTries: json.config.maxTries)
    .then((List<Model.MessageQueueItem> queuedMessages) =>
      writeAndClose(request, JSON.encode({'queue' : queuedMessages})))
    .catchError((error) => serverError(request, error.toString()));
}

