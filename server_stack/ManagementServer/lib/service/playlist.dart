part of service;

Future<http.Response> compilePlaylist(Uri dialplanCompilerServer, int playlistId, String body, String token) {
  Uri url = new Uri(
      scheme: dialplanCompilerServer.scheme,
      host: dialplanCompilerServer.host,
      port: dialplanCompilerServer.port,
      path: '/playlist/${playlistId}',
      queryParameters: {'token': token});

  return http.post(url, body: body);
}
