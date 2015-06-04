part of openreception.model;

class ClientConnection {
  int userID;
  int connectionCount;

  ClientConnection();

  ClientConnection.fromMap(Map map) {
    userID = map[_Key.userID];
    connectionCount = map[_Key.connectionCount];
  }

  Map toJson() => this.asMap;

  Map get asMap => {
    _Key.userID : userID,
    _Key.connectionCount : connectionCount
  };

}