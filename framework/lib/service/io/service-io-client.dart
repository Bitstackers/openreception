part of openreception.service.io;

class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';
  static final Logger log = new Logger(className);
  static final IO.ContentType contentTypeJson = new IO.ContentType("application", "json", charset: "utf-8");

  final IO.HttpClient client = new IO.HttpClient();

  Future<String> get(Uri resource) {
    log.finest('GET $resource');

    return client.getUrl(resource)
      .then((IO.HttpClientRequest request) => request.close())
      .then((IO.HttpClientResponse response) => _handleResponse(response, resource));
  }

  Future<String> put(Uri resource, String payload) {
    log.finest('PUT $resource');

    return client.putUrl(resource).then((IO.HttpClientRequest request) {
      request.headers.contentType = contentTypeJson;
      request.write(payload);
      return request.close();
    })
    .then((IO.HttpClientResponse response) => _handleResponse(response, resource));
  }

  Future<String> post(Uri resource, String payload) {
    log.finest('POST $resource');

    return client.postUrl(resource).then((IO.HttpClientRequest request) {
      request.headers.contentType = contentTypeJson;
      request.write(payload);
      return request.close();
    })
    .then((IO.HttpClientResponse response) => _handleResponse(response, resource));
  }

  Future<String> delete(Uri resource) {
    log.finest('DELETE $resource');

    return client.deleteUrl(resource)
        .then((IO.HttpClientRequest request) => request.close())
        .then((IO.HttpClientResponse response) => _handleResponse(response, resource));
  }

  Future<String> _handleResponse(IO.HttpClientResponse response, Uri resource) {
    try {
      this.checkResponseCode(response.statusCode);
      return extractContent(response);
    } catch (error, stacktrace) {
      log.severe('$error : $resource\n$stacktrace');
      return new Future.error(error, stacktrace);
    }
  }
}
