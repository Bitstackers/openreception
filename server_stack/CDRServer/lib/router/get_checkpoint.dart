part of cdrserver.router;

void getCheckpoints(HttpRequest request) {
  db.getCheckpointList()
    .then((List<Checkpoint> checkpointList) => writeAndClose(request, JSON.encode({'checkpoints' : checkpointList})))
    .catchError((error) => serverError(request, error.toString()));
}
