part of service;

Future<http.Response> record(Uri callflowServer, int receptionId, String filepath, String token) {
  Uri url = new Uri(
      scheme: callflowServer.scheme,
      host: callflowServer.host,
      port: callflowServer.port,
      path: '/call/reception/${receptionId}/record',
      queryParameters: {'token': token,
                        'recordpath': filepath});

  return http.post(url);
}

Future<http.Response> deleteRecording(Uri dialplanCompilerServer, String filepath, String token) {
  Uri url = new Uri(
      scheme: dialplanCompilerServer.scheme,
      host: dialplanCompilerServer.host,
      port: dialplanCompilerServer.port,
      path: '/audio',
      queryParameters: {'token': token,
                        'filepath': filepath});

  return http.delete(url);
}
