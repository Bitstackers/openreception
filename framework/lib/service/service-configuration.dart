part of openreception.service;

class RESTConfiguration {

  static final String className = '${libraryName}.RESTConfiguration';

  WebService _backed = null;
  Uri        _host;

  RESTConfiguration (Uri this._host, this._backed);

  /**
   * Returns a [ClientConfiguration] object.
   */
  Future<Model.ClientConfiguration> clientConfig() {
    Uri uri = Resource.Config.get(this._host);

    return this._backed.get (uri)
      .then((String response)
        => new Model.ClientConfiguration.fromMap(JSON.decode(response)));
  }
}
