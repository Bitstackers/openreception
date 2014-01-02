part of router;

void logDebug(HttpRequest request) {
  _log(request, 'debug');
}

void logInfo(HttpRequest request) {
  _log(request, 'info');
}

void logError(HttpRequest request) {
  _log(request, 'error');
}

void logCritical(HttpRequest request) {
  _log(request, 'critical');
}

void _log(HttpRequest request, String level) {
  extractContent(request).then((String text) {
    DateFormat dateFormat = new DateFormat('yyyy-mm-dd HH:mm:ss');
    String time = dateFormat.format(new DateTime.now());
    log('$time [${level.toLowerCase()}] $text');
    writeAndClose(request, '');
  });
}
