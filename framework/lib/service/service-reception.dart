part of openreception.service;

class RESTReceptionStore implements Storage.Reception {

  static final String className = '${libraryName}.RESTReceptionStore';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';

  RESTReceptionStore (Uri this._host, String this._token, this._backed);

  Future<Model.Reception> get(int receptionID) =>
      this._backed.get
        (appendToken(ReceptionResource.single
           (this._host, receptionID), this._token))
      .then((String response)
        => new Model.Reception.fromMap (JSON.decode(response)));

  Future<Model.Reception> create(Model.Reception reception) =>
      this._backed.post
        (appendToken
           (ReceptionResource.root(this._host), this._token), JSON.encode(reception.asMap))
      .then((String response)
        => new Model.Reception.fromMap (JSON.decode(response)));

  Future<Model.Reception> update(Model.Reception reception) =>
      this._backed.put
        (appendToken
           (ReceptionResource.single(this._host, reception.ID), this._token), JSON.encode (reception.asMap))
      .then((String response)
        => new Model.Reception.fromMap (JSON.decode(response)));

  Future<Model.Reception> save(Model.Reception reception) {
    if (reception.ID != null && reception.ID != Model.Reception.noID) {
      return this.update(reception);
    } else {
      return this.create(reception);
    }
  }

  Future<List<Model.Reception>> list({int limit: 100, Model.ReceptionFilter filter}) =>
      this._backed.get
        (appendToken
           (ReceptionResource.list(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Reception.fromMap(map)));

  Future<List<Model.Reception>> subset(int upperReceptionID, int count) =>
      this._backed.get
        (appendToken
           (ReceptionResource.subset(this._host, upperReceptionID, count), this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Reception.fromMap(map)));
}
