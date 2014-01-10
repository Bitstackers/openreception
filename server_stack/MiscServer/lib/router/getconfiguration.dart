part of miscserver.router;

void getBobConfig(HttpRequest request) {
  String path = config.bobConfigfile;
  File file = new File(path);

  file.readAsString().then((String text) {
    writeAndClose(request, text);
  }).catchError((error) {
    log(error.toString());
  });
}
