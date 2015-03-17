part of service;

Future<http.Response> compileDialplan(Uri dialplanCompilerServer, int receptionId, String dialplan, String token) {
  Uri url = new Uri(
      scheme: dialplanCompilerServer.scheme,
      host: dialplanCompilerServer.host,
      port: dialplanCompilerServer.port,
      path: '/reception/${receptionId}/dialplan',
      queryParameters: {'token': token});

  return http.post(url, body: dialplan);
}
