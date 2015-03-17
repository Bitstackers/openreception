part of service;

Future<http.Response> compileIvrMenu(Uri dialplanCompilerServer, int receptionId, String body, String token) {
  Uri url = new Uri(
      scheme: dialplanCompilerServer.scheme,
      host: dialplanCompilerServer.host,
      port: dialplanCompilerServer.port,
      path: '/reception/${receptionId}/ivr',
      queryParameters: {'token': token});

  return http.post(url, body: body);
}
