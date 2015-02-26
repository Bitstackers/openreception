part of openreception.service;

class CallFlowControl {

  static final String className = '${libraryName}.CallFlowControl';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';

  CallFlowControl (Uri this._host, String this._token, this._backed);

  /**
   * Returns a Map representation of the [Model.UserStatus] object associated
   * with [userID].
   */
  Future<Map> userStatusMap(int userID) =>
      this._backed.get
        (appendToken(Resource.CallFlowControl.userStatus
           (this._host, userID), this._token))
      .then((String response)
        => JSON.decode(response));


  /**
   * Returns a single call resource.
   */
  Future<Model.Call> get(String callID) =>
      this._backed.get
        (appendToken(Resource.CallFlowControl.single
           (this._host, callID), this._token))
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Picks up the call identified by [callID].
   */
  Future<Model.Call> pickup (String callID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.pickup
           (this._host, callID), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Originate a new call via the server.
   */
  Future<Model.Call> originate (String extension, int contactID, int receptionID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.originate
           (this._host, extension, contactID, receptionID), this._token),'')
      .then((String response)
        => new Model.Call.stub (JSON.decode(response)['call']));

  /**
   * Parks the call identified by [callID].
   */
  Future<Model.Call> park (String callID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.park
           (this._host, callID), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Parks the call identified by [callID].
   */
  Future<Model.Call> hangup (String callID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.hangup
           (this._host, callID), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Transfers the call identified by [callID] to active call [destination].
   */
  Future<Model.Call> transfer (String callID, String destination) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.transfer
           (this._host, callID, destination), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Retrives the current Call list.
   */
  Future<Iterable<Model.Call>> callList() =>
      this._backed.get
        (appendToken
           (Resource.CallFlowControl.list(this._host),this._token))
      .then((String response)
        => (JSON.decode(response)['calls'] as List).map((Map map) => new Model.Call.fromMap(map)));

  /**
   * Retrives the current Peer list.
   */
  Future<Iterable<Model.Peer>> peerList() =>
      this._backed.get
        (appendToken
           (Resource.CallFlowControl.peerList(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Peer.fromMap(map)));

  /**
   * Retrives the current Channel list as a Map.
   */
  Future<Iterable<Map>> channelListMap() {
    Uri uri = Resource.CallFlowControl.channelList(this._host);
        uri = appendToken(uri, this._token);

    return this._backed.get (uri).then((String response) => (JSON.decode(response)['channels']));
  }

  /**
   * Retrives the current Call list of queued calls.
   */
  Future<List<Model.Call>> queue() =>
      this._backed.get
        (appendToken
           (Resource.CallFlowControl.queue(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Call.fromMap(map)));
}
