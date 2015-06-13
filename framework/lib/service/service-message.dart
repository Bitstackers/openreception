part of openreception.service;

class RESTMessageStore implements Storage.Message {

  static final String className = '${libraryName}.RESTMessageStore';

  WebService _backend = null;
  Uri        _host;
  String     _token = '';

  RESTMessageStore (Uri this._host, String this._token, this._backend);

  Future<Model.Message> get(int messageID) =>
      this._backend.get
        (appendToken(Resource.Message.single
           (this._host, messageID), this._token))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.MessageQueueItem> enqueue(Model.Message message) {
    Uri uri = Resource.Message.send(this._host, message.ID);
        uri = appendToken (uri, this._token);

    return this._backend.post(uri, JSON.encode (message.asMap))
      .then(JSON.decode)
      .then((Map queueItemMap) =>
        new Model.MessageQueueItem.fromMap(queueItemMap));
  }

  Future<Model.Message> create(Model.Message message) =>
      this._backend.post
        (appendToken
           (Resource.Message.root(this._host), this._token), JSON.encode(message.asMap))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.Message> update(Model.Message message) =>
      this._backend.put
        (appendToken
           (Resource.Message.single(this._host, message.ID), this._token), JSON.encode (message.asMap))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.Message> save(Model.Message message) =>
      message.ID == Model.Message.noID
      ? create (message)
      : update (message);

  Future<Iterable<Model.Message>> list({Model.MessageFilter filter}) =>
      this._backend.get
        (appendToken
           (Resource.Message.list(this._host, filter : filter),this._token))
      .then((String response)
        => (JSON.decode(response) as Iterable).map((Map map) => new Model.Message.fromMap(map)));

}
