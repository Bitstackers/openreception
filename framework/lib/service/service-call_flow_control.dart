part of openreception.service;

class CallFlowControl {

  static final String className = '${libraryName}.CallFlowControl';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';

  CallFlowControl (Uri this._host, String this._token, this._backed);

  /**
   * Returns a single call resource.
   */
  Future<Model.Call> get(String callID) =>
      this._backed.get
        (appendToken(CallFlowControlResource.single
           (this._host, callID), this._token))
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Picks up the call identified by [callID].
   */
  Future<Model.Call> pickup (String callID) =>
      this._backed.post
        (appendToken(CallFlowControlResource.pickup
           (this._host, callID), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Originate a new call via the server.
   */
  Future<Model.Call> originate (String extension, int contactID, int receptionID) =>
      this._backed.post
        (appendToken(CallFlowControlResource.originate
           (this._host, extension, contactID, receptionID), this._token),'')
      .then((String response)
        => new Model.Call.stub (JSON.decode(response)['call']));

  /**
   * Parks the call identified by [callID].
   */
  Future<Model.Call> park (String callID) =>
      this._backed.post
        (appendToken(CallFlowControlResource.park
           (this._host, callID), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Parks the call identified by [callID].
   */
  Future<Model.Call> hangup (String callID) =>
      this._backed.post
        (appendToken(CallFlowControlResource.hangup
           (this._host, callID), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Transfers the call identified by [callID] to active call [destination].
   */
  Future<Model.Call> transfer (String callID, String destination) =>
      this._backed.post
        (appendToken(CallFlowControlResource.transfer
           (this._host, callID, destination), this._token),'')
      .then((String response)
        => new Model.Call.fromMap (JSON.decode(response)));

  /**
   * Retrives the current Call list.
   */
  Future<List<Model.Call>> list() =>
      this._backed.get
        (appendToken
           (CallFlowControlResource.list(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Call.fromMap(map)));

  /**
   * Retrives the current Peer list.
   */
  Future<List<Model.Call>> peerList() =>
      this._backed.get
        (appendToken
           (CallFlowControlResource.peerList(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Call.fromMap(map)));

  /**
   * Retrives the current Call list of queued calls.
   */
  Future<List<Model.Call>> queue() =>
      this._backed.get
        (appendToken
           (CallFlowControlResource.queue(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map((Map map) => new Model.Call.fromMap(map)));
}
