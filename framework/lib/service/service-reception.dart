part of openreception.service;

class RESTReceptionStore implements Storage.Reception {

  static final String className = '${libraryName}.RESTReceptionStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTReceptionStore (Uri this._host, String this._token, this._backend);

  Future<Model.Reception> get(int receptionID) {
    Uri url = ReceptionResource.single(this._host, receptionID, token: this._token);
    return this._backend.get(url).then((String response)
        => new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> create(Model.Reception reception) {
    Uri url = ReceptionResource.root(this._host, token: this._token);
    String data = JSON.encode(reception.asMap);
    return this._backend.put(url, data).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> update(Model.Reception reception) {
    Uri url = ReceptionResource.single(this._host, reception.ID, token: this._token);
    String data = JSON.encode(reception.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> remove(int receptionID) {
    Uri url = ReceptionResource.single(this._host, receptionID, token: this._token);
    return this._backend.delete(url).then((String response) =>
        new Model.Reception.fromMap (JSON.decode(response)));
  }

  Future<Model.Reception> save(Model.Reception reception) {
    if (reception.ID != null && reception.ID != Model.Reception.noID) {
      return this.update(reception);
    } else {
      return this.create(reception);
    }
  }

  //{int limit: 100, Model.ReceptionFilter filter}
  Future<List<Model.Reception>> list() {
    Uri url = ReceptionResource.list(this._host, token: this._token);
    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Map)
          [Model.ReceptionJSONKey.RECEPTION_LIST]
          .map((Map map) => new Model.Reception.fromMap(map))
          .toList());
  }

//  Future<List<Model.Reception>> subset(int upperReceptionID, int count) =>
//      this._backed.get
//        (appendToken
//           (ReceptionResource.subset(this._host, upperReceptionID, count), this._token))
//      .then((String response)
//        => (JSON.decode(response) as List).map((Map map) => new Model.Reception.fromMap(map)));
}
