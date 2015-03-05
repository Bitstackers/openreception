part of openreception.service.io;

/**
 * HTTP Client for use with dart:io.
 */
class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';
  static final Logger log = new Logger(className);
  static final IO.ContentType contentTypeJson = new IO.ContentType("application", "json", charset: "utf-8");

  final IO.HttpClient client = new IO.HttpClient();

  /**
   * Retrives [resource] using HTTP GET.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> get(Uri resource) {
    log.finest('GET $resource');

    return client.getUrl(resource)
      .then((IO.HttpClientRequest request) => request.close())
      .then((IO.HttpClientResponse response) => _handleResponse(response, 'GET', resource));
  }

  /**
   * Retrives [resource] using HTTP PUT, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> put(Uri resource, String payload) {
    log.finest('PUT $resource');

    return client.putUrl(resource).then((IO.HttpClientRequest request) {
      request.headers.contentType = contentTypeJson;
      request.write(payload);
      return request.close();
    })
    .then((IO.HttpClientResponse response) => _handleResponse(response, 'PUT', resource));
  }

  /**
   * Retrives [resource] using HTTP POST, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> post(Uri resource, String payload) {
    log.finest('POST $resource');

    return client.postUrl(resource).then((IO.HttpClientRequest request) {
      request.headers.contentType = contentTypeJson;
      request.write(payload);
      return request.close();
    })
    .then((IO.HttpClientResponse response) => _handleResponse(response, 'POST', resource));
  }

  /**
   * Retrives [resource] using HTTP DELETE.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> delete(Uri resource) {
    log.finest('DELETE $resource');

    return client.deleteUrl(resource)
        .then((IO.HttpClientRequest request) => request.close())
        .then((IO.HttpClientResponse response) => _handleResponse(response, 'DELETE', resource));
  }

}
