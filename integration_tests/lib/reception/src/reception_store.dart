part of or_test_fw;

abstract class Reception_Store {

  static Logger log = new Logger('Test.Reception_Store');

  /**
   * Test for the presence of hangup events when a call is hung up.
   */
  static Future isCORSHeadersPresent() {
    Uri uri = Uri.parse ('${Config.receptionStoreURI}/nonexistingpath');
    HttpClient client = new HttpClient();

    log.info('Checking CORS headers on a non-existing URL.');
    return client.getUrl(uri)
      .then((HttpClientRequest request) => request.close()
      .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail ('No CORS headers on path $uri');
        }
      }))
      .then ((_) {
        log.info('Checking CORS headers on an existing URL.');
        uri = Resource.Reception.single (Config.receptionStoreURI, 1);
        return client.getUrl(uri)
          .then((HttpClientRequest request) => request.close()
          .then((HttpClientResponse response) {
          if (response.headers['access-control-allow-origin'] == null &&
              response.headers['Access-Control-Allow-Origin'] == null) {
            fail ('No CORS headers on path $uri');
          }
      }));
    });
  }
}

