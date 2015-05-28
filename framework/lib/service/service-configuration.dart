part of openreception.service;

class RESTConfiguration {

  static final String className = '${libraryName}.RESTConfiguration';

  WebService _backend = null;
  Uri        _host;

  RESTConfiguration (Uri this._host, this._backend);

  /**
   * Returns a [ClientConfiguration] object.
   */
  Future<Model.ClientConfiguration> clientConfig() {
    Uri uri = Resource.Config.get(this._host);

    return this._backend.get (uri)
      .then((String response)
        => new Model.ClientConfiguration.fromMap(JSON.decode(response)));
  }
}
