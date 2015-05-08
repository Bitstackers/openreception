part of openreception.model;

class ClientConnection {
  int userID;
  int connectionCount;
  
  ClientConnection.fromMap(Map map) {
    userID = map[Event.Key.userID];
    connectionCount = map[Event.Key.connectionCount];
  }

  Map get asMap => {
    Event.Key.userID : userID,
    Event.Key.connectionCount : connectionCount
  };

}