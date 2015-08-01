part of openreception.model;

/**
 * Model class representing a client connection. A client connection object is
 * an information object that reveals information about how many open
 * push notification connections a user (of id [userID]) currently has.
 */
class ClientConnection {
  int userID;
  int connectionCount;


  @deprecated
  factory ClientConnection() => new ClientConnection.empty();

  /**
   * Default emtpy constructor.
   */
  ClientConnection.empty();

  /**
   * Deserializing constructor.
   */
  ClientConnection.fromMap(Map map) {
    userID = map[_Key.userID];
    connectionCount = map[_Key.connectionCount];
  }

  /**
   * JSON encoding function.
   */
  Map toJson() => this.asMap;

  /**
   * Returns a map representation of this object.
   */
  Map get asMap => {
    _Key.userID : userID,
    _Key.connectionCount : connectionCount
  };
}