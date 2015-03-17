part of service;

Future<http.Response> getAudioFileList(Uri dialplanCompilerServer, int receptionId, String token) {
  Uri url = new Uri(
      scheme: dialplanCompilerServer.scheme,
      host: dialplanCompilerServer.host,
      port: dialplanCompilerServer.port,
      path: '/reception/${receptionId}/audio',
      queryParameters: {'token': token});

  return http.get(url);
}
