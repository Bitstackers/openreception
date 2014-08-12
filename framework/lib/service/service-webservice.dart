part of openreception.service;

/**
 * Superclass for abstracting away the griddy details of
 * client/server-specific web-clients.
 */
abstract class WebService {

  static const String GET    = 'GET';
  static const String PUT    = 'PUT';
  static const String POST   = 'POST';
  static const String DELETE = 'DELETE';

  Future<String> get    (Uri path);
  Future<String> put    (Uri path, String payload);
  Future<String> post   (Uri path, String payload);
  Future<String> delete (Uri path);

  void checkResponseCode(int responseCode) {
    switch (responseCode) {
      case 200:
        break;

      case 400:
        throw new Storage.ClientError ();
        break;

      case 401:
        throw new Storage.NotAuthorized ();
        break;

      case 403:
        throw new Storage.Forbidden ();
        break;

      case 404:
       throw new Storage.NotFound();
       break;

      case 500:
        throw new Storage.ServerError();
        break;

      default:
        throw new StateError('Status (${responseCode}):');
    }
  }
}
