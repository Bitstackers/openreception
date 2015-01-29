part of openreception.service;

class RESTMessageStore implements Storage.Message {

  static final String className = '${libraryName}.RESTMessageStore';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';

  RESTMessageStore (Uri this._host, String this._token, this._backed);

  Future<Model.Message> get(int messageID) =>
      this._backed.get
        (appendToken(MessageResource.single
           (this._host, messageID), this._token))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future enqueue(Model.Message message) =>
      this._backed.post
        (appendToken
           (MessageResource.send(this._host, message.ID), this._token), JSON.encode (message.asMap));

  Future<Model.Message> create(Model.Message message) =>
      this._backed.post
        (appendToken
           (MessageResource.root(this._host), this._token), JSON.encode(message.asMap))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<Model.Message> save(Model.Message message) =>
      this._backed.put
        (appendToken
           (MessageResource.single(this._host, message.ID), this._token), JSON.encode (message.asMap))
      .then((String response)
        => new Model.Message.fromMap (JSON.decode(response)));

  Future<List<Model.Message>> list({int limit: 100, Model.MessageFilter filter}) =>
      this._backed.get
        (appendToken
           (MessageResource.list(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Message.fromMap(map)).toList());

  Future<List<Model.Message>> subset(int upperMessageID, int count) =>
      this._backed.get
        (appendToken
           (MessageResource.subset(this._host, upperMessageID, count), this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Message.fromMap(map)));
}
