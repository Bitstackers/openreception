part of openreception.service;

class CallFlowControl {

  static final String className = '${libraryName}.CallFlowControl';
  static final log = new Logger (className);

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
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state idle.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Map> userStateIdleMap(int userID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.userState
           (this._host, userID, Model.UserState.Idle), this._token), '')
      .then((String response)
        => JSON.decode(response));

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state idle.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStateIdle(int userID) =>
      userStateIdleMap(userID).then((Map map) =>
          new Model.UserStatus.fromMap(map));

  /**
   * Returns a single call resource.
   */
  Future<Model.Call> get(String callID) {
    Uri uri = Resource.CallFlowControl.single (this._host, callID);
        uri = appendToken(uri, this._token);

    return this._backed.get (uri)
    .then((String response) {
      Model.Call call;
      try {
        call = new Model.Call.fromMap (JSON.decode(response));
      } catch (error,stackTrace) {
        log.severe('Failed to parse \"$response\" as call object.');
        return new Future.error(error, stackTrace);
      }

      return call;
    });
  }

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
  Future park (String callID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.park
           (this._host, callID), this._token),'');

  /**
   * Hangs up the call identified by [callID].
   */
  Future hangup (String callID) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.hangup
           (this._host, callID), this._token),'');

  /**
   * Transfers the call identified by [callID] to active call [destination].
   */
  Future transfer (String callID, String destination) =>
      this._backed.post
        (appendToken(Resource.CallFlowControl.transfer
           (this._host, callID, destination), this._token),'');

  /**
   * Retrives the current Call list.
   */
  Future<Iterable<Model.Call>> callList() =>
      this._backed.get
        (appendToken
           (Resource.CallFlowControl.list(this._host),this._token))
      .then((String response)
        => (JSON.decode(response) as List).map
          ((Map map) => new Model.Call.fromMap(map)));

  /**
   * Retrives the current Peer list.
   */
  Future<Iterable<Model.Peer>> peerList() =>
      this.peerListMaps()
        .then((Iterable<Map> maps) =>
          maps.map((Map map) => new Model.Peer.fromMap(map)));

  /**
   * Retrives the current Peer without doing automatic casting.
   */
  Future<Iterable<Map>> peerListMaps() {
    Uri uri = Resource.CallFlowControl.peerList(this._host);
        uri = appendToken (uri, this._token);

    return this._backed.get (uri)
      .then((String response)
        => (JSON.decode(response) as List));
  }

  /**
   * Retrives the current Channel list as a Map.
   */
  Future<Iterable<Map>> channelListMap() {
    Uri uri = Resource.CallFlowControl.channelList(this._host);
        uri = appendToken(uri, this._token);

    return this._backed.get (uri).then((String response) => (JSON.decode(response)['channels']));
  }
}
