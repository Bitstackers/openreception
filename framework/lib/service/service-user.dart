part of openreception.service;

/**
 * Client for user service.
 */
class RESTUserStore implements Storage.User {
  static final String className = '${libraryName}.RESTUserStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   *
   */
  RESTUserStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<Model.User>> list() {
    Uri url = Resource.User.list(_host);
    url = appendToken(url, this._token);

    return this._backend.get(url)
      .then((String reponse) => JSON.decode (reponse))
      .then((Iterable userMaps) =>
          userMaps.map ((Map userMap) => new Model.User.fromMap(userMap)));
  }

  /**
   *
   */
  Future<Model.User> get(int userID) {
    Uri url = Resource.User.single(_host, userID);
    url = appendToken(url, this._token);

    return this._backend.get(url)
      .then((String reponse) => JSON.decode (reponse))
      .then(((Map userMap) => new Model.User.fromMap(userMap)));
  }

  /**
   *
   */
  Future<Model.User> create(Model.User user){
    Uri url = Resource.User.root(_host);
    url = appendToken(url, this._token);

    return this._backend.post(url, JSON.encode(user))
      .then((String reponse) => JSON.decode (reponse))
      .then(((Map userMap) => new Model.User.fromMap(userMap)));
  }

  /**
   *
   */
  Future<Model.User> update(Model.User user){
    Uri url = Resource.User.single(_host, user.ID);
    url = appendToken(url, this._token);

    return this._backend.put(url, JSON.encode(user))
      .then((String reponse) => JSON.decode (reponse))
      .then(((Map userMap) => new Model.User.fromMap(userMap)));
  }

  /**
   *
   */
  Future remove(int userId) {
    Uri url = Resource.User.single(_host, userId);
    url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<Model.UserGroup>> userGroups(int userID) {
    Uri url = Resource.User.userGroup(_host, userID);
    url = appendToken(url, this._token);

    return this._backend.get(url)
      .then((String reponse) => JSON.decode (reponse))
      .then((Iterable groupMaps) =>
          groupMaps.map ((Map groupMap) =>
              new Model.UserGroup.fromMap(groupMap)));
  }

  /**
   *
   */
  Future<Iterable<Model.UserGroup>> groups() {
    Uri url = Resource.User.group(_host);
    url = appendToken(url, this._token);

    return this._backend.get(url)
      .then((String reponse) => JSON.decode (reponse))
      .then((Iterable groupMaps) =>
          groupMaps.map ((Map groupMap) =>
              new Model.UserGroup.fromMap(groupMap)));
  }

  /**
   *
   */
  Future joinGroup(int userID, int groupID) {
    Uri url = Resource.User.userGroupByID(_host, userID, groupID);
    url = appendToken(url, this._token);

    return this._backend.put(url,'');
  }

  /**
   *
   */
  Future leaveGroup(int userID, int groupID) {
    Uri url = Resource.User.userGroupByID(_host, userID, groupID);
    url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<Model.UserIdentity>> identities(int userID) {
    Uri url = Resource.User.userIndentities(_host, userID);
    url = appendToken(url, this._token);

    return this._backend.get(url)
      .then((String reponse) => JSON.decode (reponse))
      .then((Iterable identityMaps) =>
          identityMaps.map ((Map identityMap) =>
              new Model.UserIdentity.fromMap(identityMap)));

  }

  /**
   *
   */
  Future<Model.UserIdentity> addIdentity(Model.UserIdentity identity) {
    Uri url = Resource.User.userIndentities(_host, identity.userId);
    url = appendToken(url, this._token);

    return this._backend.put(url, JSON.encode (identity))
      .then((String reponse) => JSON.decode (reponse))
      .then((Map identityMap) =>
         new Model.UserIdentity.fromMap(identityMap));
  }

  /**
   *
   */
  Future removeIdentity(Model.UserIdentity identity) {
    Uri url = Resource.User.userIndentity(_host, identity.userId, identity.identity);
    url = appendToken(url, this._token);

    return this._backend.delete(url);

  }
}
