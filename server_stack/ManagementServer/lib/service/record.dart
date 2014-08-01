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
